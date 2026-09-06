#!/usr/bin/env python3
"""gemini_shim.py — speak Gemini, think OpenAI, route to OUR gateway. (v0 2026-09-06)

The "boom" integration: plugins with hardcoded Gemini endpoints (KGA etc.)
get pointed at this shim; it translates generateContent <-> chat/completions
and forwards to our router (:8705) -> POP fleet. No Google, no key leaves the
box (the ?key= param is accepted and ignored).

  SHIM_PORT      (default 8706)         SHIM_MODEL  (default amalia-9b)
  SHIM_UPSTREAM  (default http://127.0.0.1:8705/v1/chat/completions)

Test: python3 gemini_shim.py  then curl the endpoint below with a Gemini body.
"""
import json, os, re, sys, urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("SHIM_PORT", "8706"))
MODEL = os.environ.get("SHIM_MODEL", "amalia-9b")
UPSTREAM = os.environ.get("SHIM_UPSTREAM", "http://127.0.0.1:8705/v1/chat/completions")

def to_openai(body):
    msgs = []
    si = body.get("systemInstruction") or body.get("system_instruction")
    if si:
        txt = " ".join(p.get("text", "") for p in si.get("parts", []))
        if txt.strip(): msgs.append({"role": "system", "content": txt})
    for c in body.get("contents", []):
        txt = " ".join(p.get("text", "") for p in c.get("parts", []))
        role = "assistant" if c.get("role") == "model" else "user"
        msgs.append({"role": role, "content": txt})
    gc = body.get("generationConfig") or {}
    out = {"model": MODEL, "messages": msgs}
    if gc.get("maxOutputTokens"): out["max_tokens"] = gc["maxOutputTokens"]
    if gc.get("temperature") is not None: out["temperature"] = gc["temperature"]
    return out

def to_gemini(oa):
    ch = (oa.get("choices") or [{}])[0]
    txt = ((ch.get("message") or {}).get("content")) or ""
    return {"candidates": [{"content": {"role": "model", "parts": [{"text": txt}]},
                            "finishReason": ch.get("finish_reason", "STOP")}],
            "model": oa.get("model", MODEL), "shim": True}

class H(BaseHTTPRequestHandler):
    def log_message(self, fmt, *a):
        sys.stderr.write("[shim] %s %s\n" % (self.command, self.path))
    def _send(self, code, obj):
        b = json.dumps(obj).encode()
        self.send_response(code); self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(b))); self.end_headers(); self.wfile.write(b)
    def do_GET(self):
        if self.path.rstrip("/").endswith("/models") or re.search(r"/models/[^:/]+$", self.path):
            self._send(200, {"models": [{"name": "models/gemini-shim", "supportedGenerationMethods": ["generateContent"]}]})
        else: self._send(200, {"ok": True, "shim": MODEL})
    def do_POST(self):
        if ":generateContent" not in self.path and ":streamGenerateContent" not in self.path:
            return self._send(404, {"error": {"code": 404, "message": "unsupported path"}})
        n = int(self.headers.get("Content-Length", 0)); raw = self.rfile.read(n)
        try: body = json.loads(raw or b"{}")
        except Exception: return self._send(400, {"error": {"code": 400, "message": "bad json"}})
        req = to_openai(body)
        data = json.dumps(req).encode()
        r = urllib.request.Request(UPSTREAM, data=data, headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(r, timeout=120) as resp:
                return self._send(200, to_gemini(json.loads(resp.read())))
        except urllib.error.HTTPError as e:
            try: detail = json.loads(e.read()).get("error", {}).get("message", str(e))
            except Exception: detail = str(e)
            self._send(502, {"error": {"code": 502, "message": "upstream: %s" % detail}})
        except Exception as e:
            self._send(502, {"error": {"code": 502, "message": "upstream unreachable: %s" % e}})

if __name__ == "__main__":
    print("gemini-shim on :%d -> %s (model %s)" % (PORT, UPSTREAM, MODEL))
    HTTPServer(("127.0.0.1", PORT), H).serve_forever()
