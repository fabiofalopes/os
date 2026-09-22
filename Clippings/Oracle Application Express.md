---
title: "Oracle Application Express"
source: "https://en.wikipedia.org/wiki/Oracle_Application_Express#Low_Code_environment"
author:
  - "[[Wikipedia]]"
published: 2004-09-06
created: 2026-09-22
description:
tags:
  - "clippings"
---
**Oracle APEX** (Oracle Application Express) is a [low-code application development platform](https://en.wikipedia.org/wiki/Low-code_development_platform "Low-code development platform") developed by [Oracle Corporation](https://en.wikipedia.org/wiki/Oracle_Corporation "Oracle Corporation"). APEX is used for developing and deploying [cloud](https://en.wikipedia.org/wiki/Cloud_computing "Cloud computing"), [mobile](https://en.wikipedia.org/wiki/Mobile_app "Mobile app") and desktop [applications](https://en.wikipedia.org/wiki/Application_software "Application software"). It has a web-based [integrated development environment](https://en.wikipedia.org/wiki/Integrated_development_environment "Integrated development environment") (IDE) that includes tools such as [wizards](https://en.wikipedia.org/wiki/Wizard_\(software\) "Wizard (software)"), [drag-and-drop](https://en.wikipedia.org/wiki/Drag-and-drop "Drag-and-drop") layout builders, and property editors.

## Background

APEX is a feature of the [Oracle Database](https://en.wikipedia.org/wiki/Oracle_Database "Oracle Database"). It is a part of the [Oracle Cloud](https://en.wikipedia.org/wiki/Oracle_Cloud_Platform "Oracle Cloud Platform") within the Autonomous Database Cloud Services and the stand-alone APEX Application Development service.[^3]

Oracle APEX has had name changes since its creation in 2000, including:

## History

APEX was created by Oracle developer Michael Hichwa following his earlier project, WebDB. While building an internal [web calendar](https://en.wikipedia.org/wiki/Web_calendar "Web calendar"), Hichwa collaborated with fellow Oracle employee Joel Kallman to develop Flows. Together, they co-developed the web calendar, adding features to Flows as they needed them to develop the calendar. Early builds of Flows had no front-end, so all changes to an application were made in [SQL Plus](https://en.wikipedia.org/wiki/SQL_Plus "SQL Plus") via insert, update, and delete commands.[^8]

With version 5.2, the numbering system was changed to align with the year and quarter of the release, renaming it to 18.1. This change is consistent with Oracle's change in numbering nomenclature.

## Low-code environment

Oracle APEX is a low-code development platform, a type of environment that can trace its origins to [fourth-generation programming languages](https://en.wikipedia.org/wiki/Fourth-generation_programming_language "Fourth-generation programming language") and [rapid application development](https://en.wikipedia.org/wiki/Rapid_application_development "Rapid application development") (RAD) tools.

APEX allows users to build [web applications](https://en.wikipedia.org/wiki/Web_application "Web application") with a " [no code](https://en.wikipedia.org/wiki/No-code_development_platform "No-code development platform") " graphical user interface. However, when the requirements are more complex, APEX allows the extension of the low-code objects through a declarative framework. This framework lets the developer define custom logic, business rules, and user interfaces. The developer can do this through the inclusion of [SQL](https://en.wikipedia.org/wiki/SQL_injection "SQL injection"), [PL/SQL](https://en.wikipedia.org/wiki/PL/SQL "PL/SQL"), [HTML](https://en.wikipedia.org/wiki/HTML "HTML"), [JavaScript](https://en.wikipedia.org/wiki/JavaScript "JavaScript"), or [CSS](https://en.wikipedia.org/wiki/CSS "CSS"), as well as APEX plug-ins.[^9] [^10]

## Security

APEX applications are subject to the same level of [application security](https://en.wikipedia.org/wiki/Application_security "Application security") risks as other web-based applications built on more direct technologies such as [PHP](https://en.wikipedia.org/wiki/PHP "PHP"), [ASP.NET](https://en.wikipedia.org/wiki/ASP.NET "ASP.NET"), and [Java](https://en.wikipedia.org/wiki/Java_\(programming_language\) "Java (programming language)"). However, the Application Builder interface includes a utility called Advisor, which provides a basic assessment of an application’s security posture.

The two main vulnerabilities that affect APEX applications are [SQL injection](https://en.wikipedia.org/wiki/SQL_injection "SQL injection") and [cross-site scripting (XSS)](https://en.wikipedia.org/wiki/Cross-site_scripting "Cross-site scripting").[^11]

**SQL Injection**

APEX applications inherently use PL/SQL constructs as the base [server-side](https://en.wikipedia.org/wiki/Client%E2%80%93server_model "Client–server model") language and access data via PL/SQL blocks.[^12] An APEX application will use PL/SQL to implement authorization and to conditionally display web page elements. Because of this, APEX applications can suffer from an SQL injection when these PL/SQL blocks do not correctly validate and handle [malicious user](https://en.wikipedia.org/wiki/Security_hacker "Security hacker") input.[^13]

Oracle implemented a special variable type for APEX called *Substitution Variables* (with a syntax of "&NAME."); however, these are insecure and can lead to SQL injections. When an injection occurs within a PL/SQL block, an attacker can inject an arbitrary number of queries or statements to execute. Escaping special characters and using bind variables can reduce, but not remove, XSS and SQL injection vulnerabilities.

**Cross-Site Scripting (XSS)**

[XSS](https://en.wikipedia.org/wiki/XSS "XSS") vulnerabilities arise in APEX applications just like in other [web application](https://en.wikipedia.org/wiki/Web_application "Web application") languages. To counteract this, Oracle provides the htf.escape\_sc() function to replace literal characters with HTML entity names and avoid undesired behaviors.[^14]

A developer can use authorization schemes to manage access to resources like pages and items within an APEX application. To ensure proper security, these schemes must be consistently applied across all relevant resources. An example of inconsistent access control arises when an authorization scheme is applied to a button item but not to the process linked to that button. This inconsistency could allow a user to trigger the process directly via JavaScript, bypassing the button entirely.

## Third-party libraries

Developers may improve and extend APEX applications by using third-party libraries. Among them are [JQuery Mobile](https://en.wikipedia.org/wiki/JQuery_Mobile "JQuery Mobile") (HTML 5-based user interface),[^15] [JQuery UI](https://en.wikipedia.org/wiki/JQuery_UI "JQuery UI") (user interface for the web),[^16] [AnyChart](https://en.wikipedia.org/wiki/AnyChart "AnyChart") ([JavaScript](https://en.wikipedia.org/wiki/JavaScript "JavaScript") / [HTML 5](https://en.wikipedia.org/wiki/HTML5 "HTML5") charts),[^17] [CKEditor](https://en.wikipedia.org/wiki/CKEditor "CKEditor") (web text editor),[^18] and others. Oracle claims that applying the latest APEX patches ensures that the external libraries bundled with the platform are updated in tandem, which theoretically enhances application stability and security.[^19] However, many of the libraries are updated more frequently than APEX patches are released, requiring developers to monitor and manually apply updates as necessary to maintain compatibility and security.[^20] [^21]

## APEX and Oracle Database Express Edition (XE)

[Oracle](https://en.wikipedia.org/wiki/Oracle_Corporation "Oracle Corporation") APEX can be run inside Oracle Database Express Edition (XE), a free entry-level database. Although the functionality of APEX isn't intentionally limited when running on XE, the limitations of the database engine may prevent some APEX features from functioning. Furthermore, Oracle XE has limits for [CPU](https://en.wikipedia.org/wiki/Central_processing_unit "Central processing unit"), memory, and disk usage.[^22]

[^1]: ["Oracle Application Express - Downloads"](http://www.oracle.com/technetwork/developer-tools/apex/downloads/index.html). Oracle. Retrieved December 10, 2015.

[^2]: ["Oracle Application Express Documentation"](https://docs.oracle.com/cd/E59726_01/doc.50/e39143/toc.htm). Oracle Help Center.

[^3]: ["Oracle Application Express (APEX): Overview"](https://www.oracle.com/technetwork/developer-tools/apex/overview/apex-overview-otn-4491378.pdf) (PDF). *[Oracle Corporation](https://en.wikipedia.org/wiki/Oracle_Corporation "Oracle Corporation")*.

[^4]: ["Welcome to Flows for APEX"](https://web.archive.org/web/20210924191941/https://mt-ag.github.io/apex-flowsforapex/). *apex-flowsforapex*. Archived from [the original](https://mt-ag.github.io/apex-flowsforapex/) on September 24, 2021. Retrieved September 24, 2021.

[^5]: ["Implementing Oracle API Platform Cloud Service"](https://www.packtpub.com/product/implementing-oracle-api-platform-cloud-service/9781788478656). *Packt*. Retrieved September 24, 2021.

[^6]: ["how i get benefit from project marble"](https://forums.oracle.com/ords/apexds/post/how-i-get-benefit-from-project-marvel-3246). *forums.oracle.com*. September 17, 2002.

[^7]: ["Appendix: Oracle APEX"](https://docs.oracle.com/cd/E97588_01/siocs/pdf/180/html/siocs_implementation_guide/appendix_apex.htm). *docs.oracle.com*. Retrieved January 26, 2025.

[^8]: . [Apress](https://en.wikipedia.org/wiki/Apress "Apress"). Michael Hichwa is the original developer and architect of Oracle Application Express (APEX), aka HTML DB. Michael created APEX as a 100% rewrite of an earlier browser-based application development tool he also created, called Oracle WebDB. He had invaluable technical assistance and guidance from Tom Kyte and the addition of Joel Kallman as a co-developer. Michael and Joel have led APEX development efforts since 1999

[^9]: Kallman, Joel. ["From Low Code to High Control"](https://blogs.oracle.com/oraclemagazine/from-low-code-to-high-control). Retrieved November 27, 2017.

[^10]: ["Low Code with Oracle Application Express"](https://apex.oracle.com/lowcode/). *apex.oracle.com*. Retrieved November 27, 2017.

[^11]: ["Securing Vulnerability Exploits with Apex – Part 3"](https://content.dsp.co.uk/apex/securing-vulnerability-exploits-apex-part-3). *content.dsp.co.uk*. Retrieved October 8, 2024.

[^12]: Alpern, D.; Agrawal, S.; Baer, H.; Castledine, S.; Chang, T.; Cheng, B.; Dani, R.; Decker, R.; Iyer, C. ["Overview of PL/SQL"](https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/overview.html#GUID-8E5695A2-F639-4480-9C61-0AE5CF0C16BC). *Oracle Help Center*. Retrieved January 24, 2025.

[^13]: ["Using Oracle APEX"](https://enterprisearchitecture.harvard.edu/using-oracle-apex). *enterprisearchitecture.harvard.edu*. Retrieved January 24, 2025.

[^14]: ["Fusion Middleware PL/SQL Web Toolkit Reference"](https://docs.oracle.com/cd/E28280_01/portal.1111/e12042/pshtp.htm). *docs.oracle.com*. Retrieved October 8, 2024.

[^15]: ["Building a Mobile Web Application Using Oracle Application Express 5.0"](http://www.oracle.com/webfolder/technetwork/tutorials/obe/db/apex/r50/CreMobileApp_apex50EA/CreMobileApp_apex50EA.html). Oracle.

[^16]: ["Application Express Application Builder User's Guide"](https://docs.oracle.com/database/121/HTMDB/app_comp001.htm#HTMDB29024). Oracle.

[^17]: ["Oracle APEX: Using AnyChart products with Oracle Application Express (APEX)"](http://www.anychart.com/products/oracleapex/). AnyChart.

[^18]: ["Oracle chooses FCKeditor for Application Express"](http://ckeditor.com/blog/Oracle-chooses-FCKeditor-for-Application-Express). CKEditor.com.

[^19]: ["Oracle Application Express (APEX) Patches"](https://oracle-base.com/articles/misc/oracle-application-express-apex-patches). Oracle Base. Retrieved December 30, 2024.

[^20]: ["Goodies - APEX 4.2.2 included Libraries"](http://dgielis.blogspot.ru/2013/05/goodies-apex-422-included-libraries.html). Dimitri Gielis Blog. May 8, 2013. Retrieved December 10, 2015.

[^21]: ["APEX 5 first peek"](http://www.grassroots-oracle.com/2014/03/apex-5-first-peek.html). Grassroots Oracle. March 17, 2014. Retrieved December 10, 2015.

[^22]: ["Limitations of the Express Edition"](http://docs.oracle.com/cd/E17781_01/install.112/e18803/toc.htm#BEIIIEDG). Oracle Corporation. Retrieved May 22, 2013.