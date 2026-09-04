---
title: "At-Home Cyberwar: A Guide to Deauthentication Attacks"
source: "https://www.addielamarr.com/at-home-cyberwar-a-guide-to-deauthentication-attacks/"
author:
  - "[[Addie LaMarr]]"
published: 2024-05-11
created: 2026-09-04
description: "Who knew that network sabotage via deauthentication attacks could be a love language? Last week, I ventured into the world of MAC spoofing with a simple aim: to introduce a bit of harmless disruption to Antonio's computer. It's our way of keeping things fun in our nerdy relationship. Observing his puzzled reactions as his internet"
tags:
  - "clippings"
---
**Who knew that network sabotage via deauthentication attacks could be a love language?**

Last week, I ventured into the world of [MAC spoofing](https://www.addielamarr.com/unlocking-mac-spoofing-secrets-a-fun-guide-to-network-exploration/ "Unlocking MAC Spoofing Secrets: A Fun Guide to Network Exploration") with a simple aim: to introduce a bit of harmless disruption to Antonio’s computer. It’s our way of keeping things fun in our nerdy relationship. Observing his puzzled reactions as his internet connection dropped unexpectedly proved quite entertaining.

Fast forward to this week, and things have escalated—thanks to the timely arrival of my new WiFi adapter. It was time to level up my game and introduce a bit more sophistication into our ongoing cyber skirmish.

![Deauthentication Attacks](https://www.addielamarr.com/wp-content/uploads/2024/04/divider3-2.png)

Deauthentication Attacks

**Enter the world of Deauthentication Attacks.**

### What’re Deauthentication Attacks?

![](https://www.addielamarr.com/wp-content/uploads/2024/05/DEAUTHENTICATION-ATTACKS.jpg)

A deauthentication attack is a type of network nuisance that targets the communication between a router and the devices connected to it. Essentially, it involves sending a flood of [deauth packets](https://publish.obsidian.md/addielamarr/deauth+packets) to a connected device (like Antonio’s unsuspecting laptop), tricking it into thinking that it’s been kicked off the network. The result? His device gets disconnected until I hit ctrl + c (this stops it from sending packets).

![Deauthentication Attacks](https://www.addielamarr.com/wp-content/uploads/2024/04/divider3-2.png)

Deauthentication Attacks

### How to Pull Off Deauthentication Attacks

**Step 1: Equip with Kali Linux**

Equipped with [Kali Linux](https://publish.obsidian.md/addielamarr/Kali+Linux), an operating system tailored for security professionals, I began to prepare my network attack. Kali Linux features [Aircrack-ng](https://publish.obsidian.md/addielamarr/Aircrack-ng), a robust suite of tools designed specifically for auditing network security.

**Update System Repositories:**

```
sudo apt-get update
```

**Install Aircrack-ng:**  
This suite includes all the tools needed for network monitoring and attacks.

```
sudo apt-get install aircrack-ng
```

**Step 2: Activate Monitor Mode**

First things first, I had to put my [new WiFi adapter](https://www.alfa.com.tw/products/awus036ach?variant=36473965871176) into [monitor mode](https://publish.obsidian.md/addielamarr/Change+MAC+from+Managed+to+Monitor+Mode). This allows the adapter to listen in on all network traffic, picking up the essential data needed for the attack:

```
sudo airmon-ng start wlan1
```

**Step 3: Scan and Select the Target Network**

Next, I used `airodump-ng` to scan all available networks. I was particularly looking for our own network to ensure the prank remained harmless:

```
sudo airodump-ng --band bg wlan1
```

Once I located our home network, I continued to monitor it specifically:

```
sudo airodump-ng --bssid F8:23:B2:B9:50:A8 --channel 2 --write test wlan1
```

During this monitoring phase, I collected data packets and noted down essential information such as the BSSID and channel, which are crucial for targeting the attack accurately.

![](https://www.addielamarr.com/wp-content/uploads/2024/05/image-1.png)

Screenshot from Udemy tutorial.

**Step 4: Execute the Deauthentication Attack**

With all the necessary information at hand, I was ready to launch the deauthentication attack. I targeted my boyfriend’s device specifically to disconnect it from our network:

```
sudo aireplay-ng --deauth 100000 -a F8:23:B2:B9:50:A8 -c 80:E6:50:22:A2:E8 wlan1
```

In this command, `100000` represents the number of deauthentication packets sent to ensure continuous disruption. This caused his device to disconnect repeatedly.

![](https://www.addielamarr.com/wp-content/uploads/2024/05/image-3.jpg)

**Step 5: Monitor the Attack Impact**

This step involves observing the effects of the deauthentication attack. Monitoring how the target device attempts to reconnect to the network provides insights into the network’s resilience and the effectiveness of the attack.

![Deauthentication Attacks](https://www.addielamarr.com/wp-content/uploads/2024/04/divider3-2.png)

Deauthentication Attacks

### Why Do This?

You might be wondering why I choose to engage in such digital antics. In our tech-driven lives, these harmless pranks inject a bit of excitement and offer us both valuable learning experiences in network security—though I admit, I’m currently leading in our friendly rivalry.

It’s important to stress that these pranks are confined strictly to our personal devices and our private network. We always maintain a spirit of fun, and I’m acutely aware that conducting such activities on any other network would be both illegal and unethical.

**So, what’s the takeaway?**

Engaging in these light-hearted security exercises does more than just stir up laughter—it sharpens our skills and keeps our digital defenses strong.

![Deauthentication Attacks](https://www.addielamarr.com/wp-content/uploads/2024/04/divider3-2.png)

Deauthentication Attacks