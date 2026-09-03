---
id: MOC-obfuscation
type: moc
---
# Obfuscation MOC
Techniques observed (or claimed) in the target, one linked claim each:
- Minified bundle + source-map accident: [[../20-claims/clm-0001|CLM-0001]]
- Obfuscated telemetry in date-formatting functions (DEMONSTRATED 2.1.91+2.1.196, base64+XOR-91):
  [[../20-claims/clm-0011|CLM-0011]]; removed in 2.1.246: [[../20-claims/clm-0012|CLM-0012]]
- Invisible-Unicode steganographic channel in system prompt (DEMONSTRATED):
  [[../20-claims/clm-0011|CLM-0011]]
- Anthropic-specific beta headers as protocol friction: [[../20-claims/clm-0004|CLM-0004]]
This MOC populates as DISASSEMBLER findings land.
- Bun standalone ELF container (native-binary era): app JS plaintext-extractable
  via strings; 246 carries zstd-magic residue needing a proper extractor (EXP-0003)
