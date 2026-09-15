---
title: "ADP Developer Site"
source: "https://developer-stage.adobe.com/dev-docs-reference/"
author:
published:
created: 2026-09-15
description: "A guide introducing the Next Generation Developer Website and the transition from Gatsby to Edge Delivery Services"
tags:
  - "clippings"
---
## Welcome to the new Developer Website!

The ADP Developer Site Documentation provides a comprehensive list of guides on how to build documentation on the developer.adobe.com platform.

## What is DevDocs

---

DevDocs is the technical documentation infrastructure that powers the Developer Website's comprehensive developer resources. Built on Edge Delivery Services, DevDocs provides product teams with a streamlined authoring experience where they can create and maintain technical documentation in markdown within their dedicated repositories in the AdobeDocs GitHub organization. Teams leverage configuration and content blocks to structure their documentation, ensuring consistency across the platform. With the flexibility to preview content in local development environments or staging, product teams can refine their documentation before deploying to production, making it accessible to developers worldwide.

## What is DevBiz

---

DevBiz is the marketing infrastructure that enables product teams to create compelling marketing pages on the Developer Website. Designed for ease of use, DevBiz allows teams to author content directly in Google Docs within organized Google Drive folders, eliminating the need for technical expertise. Product owners can draw from a rich library of reusable content blocks available in the Developer Website Sidekick, making it simple to create professional, on-brand marketing pages. The integrated Sidekick tool provides a seamless workflow for previewing changes and confidently deploying content to staging and production environments, ensuring marketing pages are polished and ready to engage developers.

## Frequently Asked Questions

---

### What is the difference between DevBiz and DevDocs?

- The Adobe Developer Website DevBiz mircosites are intended to be for marketing or landing pages. The technology stack for DevBiz page are through Google Docs and you need an Adobe Google Account to author and deploy pages.
- The Adobe Developer Website DevDocs microsites are intended to be technical documentation and support features such as code blocks and API references. The content is managed via a AdobeDocs Github repository and is authored by Markdown. EDS is the technology stack that DevDocs utilizes.

### What is the Next Generation Developer Website?

The Next Generation Developer Website is the effort to unite the Developer Website under Edge Delivery Services as the technology stack.

### Why the change from Gatsby to EDS?

- Microsites on the Developer Website have become large and complex. As a result, there is an increased maintenance and support load that is unsustainable for the size of our team.
- Additionally, Gatsby has been acquired recently and support for its framework is unknown.
- The Developer Website team supports the platform for product teams to deploy documentation and marketing pages. Because we support teams across Adobe, we need to maintain the look and feel of the Website in a similar environment for the Developer Experience. When a change to the Global Navigation or Footer is needed, or an update across the whole platform, we need to push out a site wide theme update which is difficult to do withe current Gatsby setup.

### Why did we select Edge Delivery Services?

- EDS is an Adobe product; thus giving us better access and insight to the product team EDS recently launched a new feature where content can live in GitHub repos.
- Gatsby users keep their repos and also the same markdown content.
- No more react, less depenendecy to node modules Gatsby/React eco system, pure vanilla JS and CSS
- Fast publish times and no more downtime

### What are some benefits to EDS?

- Optimized content blocks for performance, analytics, accessibility and mobile responsiveness.
- Additional features such as A/B testing and RUM analytics will be offered by EDS.
- Currently, when pushing a deployment on Gatsby, there is downtime from 1-5 minutes as the changes are being pushed to production. In EDS, there will be no downtime and deployments will not cause their microsite to 404 while the new changes are pushed to production.

## Architecture

---

**Gatsby EDS Architecture:**

**Next Gen Architecture:**

![NextGenArchitecture](https://developer-stage.adobe.com/dev-docs-reference/media_178f633e20716160903ac08b67580bc4e86790098.png?width=750&format=webply&optimize=medium)

Was this helpful?