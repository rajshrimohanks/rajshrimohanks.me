+++ 
draft = false
date = 2024-06-06T15:54:42+05:30
title = "Moving away from GoDaddy DNS to Google Cloud DNS"
description = ""
slug = ""
authors = []
tags = ["devops","gcp","google cloud","godaddy"]
categories = ["tech"]
externalLink = ""
series = []
+++

Back when we started with IQZ around 2016, our primary domain name [iqzsystems.com](iqzsystems.com) was with GoDaddy. GoDaddy is a famous registrar and domain name system provider for ages now, but over time, they've also grown notorious for shoddy service and terrible API integration, amongst other things. However, since our primary domain name was with GoDaddy, we ended up getting our other domains as well from them. Our DNS (Domain Name System) management was also tied to GoDaddy as a result.

Before we proceed further, I'm sure a lot of you are confused with what a DNS is and what is all this GoDaddy stuff is about. So here's an explainer to start with.

## What is a DNS?

Anything we host on the internet - be it a website, webapp or just an API server - must be hosted on a server of some sorts. The way we identify a server in a network is through its IP address. Each server on the internet has its own IP address. (This is a simplification as we can have networks within networks, and a single server can also have multiple network interfaces - but it serves to illustrate our scenario here). In order to access the website/webapp/API, our browsers need to know the IP address of the server. However, it is difficult for people to remember the IP addresses of all the servers they need to access. Can you imagine typing in `142.250.105.139` in your browser every time you want to search something on the internet? (If you haven't guessed it already, that's one of the IP addresses for `google.com` 🙂) This is why we have **domain names** - friendly names which map to a server. So instead of typing in a cryptic IP address, you can type in `google.com` and your browser will take you there.

But how does a browser know what IP address "google.com" is pointing at? This is where domain name servers help. **Domain name servers** are servers which map a domain name to its corresponding records. There are tons of domain name servers around the world and you can use any of them. By default, your computer would be configured to use the DNS set by your internet service provider or your active directory tenant host. A DNS server is simply a large lookup table. It has a constantly updating list of domain names and their records. But where does a DNS server get its records from?

When a website/webapp owner wants to host something on the internet, they upload their files to a server and purchase a domain name from a **domain name registrar**. Internet Corporation for Assigned Names and Numbers (ICANN) is the governing body for internet domains around the world and they decide what Top Level Domains (TLD - the final part of your domain name - like `.com`, `.org`, `.io` etc.) can be used across the world. However, they don't sell the domain names themselves. They leave that to domain name registrars like GoDaddy, Namecheap, Name.com, etc. So a site owner needs to go to one of these registrars and purchase a domain.

Usually, a domain name registrar also acts as a Domain Name System (DNS) provider. DNS basically says what subdomain should map to what record. For example, let's assume we've purchased a domain called `superawesomeapp.com`. And we want to make `www.superawesomeapp.com` (here, `www` is the subdomain - we only pay for the domain name itself. We can use any number of sub-domains below that domain) point to a server with IP `35.42.118.8` (just an example), then we can create an A record (**A**ddress record) on the domain name server in the DNS with the host as `www` and value as `35.42.118.8`. The domain name server then serves to populate the domain name servers across the world with the value. Does this mean that a registrar domain name server has information about all the domain name servers across the world? No. It's actually the other way around. And the way it works is through two major types of domain name servers - authoritative and recursive.

### Authoritative vs Recursive Name Servers

**Authoritative name servers** respond to a domain name query - for example, if you submit a query asking for the address associated with `www.superawesomeapp.com`, they would respond back with `35.42.118.8`. This is fine if the domain name server has the information. But what if it doesn't?

**Recursive name servers** respond to a domain name query, but if they can't find the information in their database, they ask the nameserver up their hierarchy for the information. So yes, a name server can point to another name server. This also means, most name servers across the world (such as the one used by your ISP) are recursive.

When we as a site owner set a record for a domain, we do so in a Authoritative name server. This record then gets propagated downstream to other name servers via recursive calls.

## Splitting the DNS from the domain name registrar

While a registrar can act as a DNS provider, it usually is not considered best practice to use them as such. There are many reasons to it, like the following:

- Domain names are valid for a year, post which we'd have to renew them with the registrar. We don't want our domain records to be locked in with the registrar when we switch domain names or transfer the domain name from one registrar to another.
- Traditionally, domain name registrars have terrible API support for automation purposes.
- Traditionally, domain name registrars have pretty bad multi-user support for management.
- Domain name registrars have lower feature sets when it comes to actually managing domains.
- Domain name registrars usually have slower servers than dedicated DNS providers simply because their primary business is selling domains.

The above is true for most traditional domain name registrars out there, including our registrar - GoDaddy. So it's best to let registrars do what they do best - selling domains - and move control of the DNS management to dedicated DNS providers like Cloudflare, AWS Route 53, Google Cloud DNS, etc.

Domain name registrars allow us to specify the authoritative name server information (usually a bunch of domain names or IPs) which should be used for a domain. In order to split the DNS from the registrar, all we have to do is specify our own name server information instead of the default ones used by our registrar.

## Why we decided to switch from GoDaddy to Google Cloud DNS

At IQZ, we've been using Google Cloud Platform (GCP) since long. GCP provides us a DNS service in the form of Google Cloud DNS. Cloud DNS, apart from being integrated to GCP, has a whole bunch of advantages over GoDaddy's DNS:

- **Cloud DNS uses Google's Anycast nameservers across the world.** This means changes reflect in seconds across the world. With GoDaddy, we had to wait up to 8 hours at times for the records to propagate.
- **We can do failover and geolocation based routing on DNS.** While we don't use it now, it has great potential for the future when we have our audience around the world and during disaster recovery scenarios.
- **Support for private and container native DNS zones.** What this means is that we can have a domain name completely local to our private network or our container network isolating them from the rest of the world.
- **Cloud DNS is built around GCP IAM.** This means we can control access to managing the DNS via our IAM policies. With GoDaddy, access was limited to just me and TK, requiring our presence to make changes. This was fine back when IQZ was 20 people. But with more than 100 active developers and counting, the GoDaddy mechanism no longer scales.
- **We can fully manage Cloud DNS with Terraform.** I can't even begin to say how convenient this is to DNS management. We are big fans of having every bit of configuration in code and this just nails it.
- **Unlimited automation potential.** Because Cloud DNS supports Terraform and API bsaed configuration, we no longer have to manually set the DNS records after a service is created in our cloud. We can simply chain the creation to our service deployment pipeline.

As you can see, there are whole bunch of advantages. Our primary motivators however, were the last three points.

## Migration process

While not at a level of some big companies out there, migrating our DNS records was still not going to be simple. We have a whole bunch of domain names we've been using. And our primary domain (iqzsystems.com) is extremely critical since our mail servers also depend on it in addition to our website and other apps. So before we went ahead and did things, we set ourselves some goals:

- Move the following domains to Cloud DNS:
  - iqzsystems.com (GoDaddy)
  - iqzsystems.io (GoDaddy)
  - iqzapps.com (Namecheap)
  - iqzplus.com (Namecheap)
- Perform a zero-downtime migration. We didn't want anyone's work be impacted by this change.
- Completely use IaaC with our established Terraform and Azure DevOps pipelines.
- Provide a means for anyone in the organization to request a change in the DNS without it being dependent on a specific user.

We chose the domains specified above because they are the ones used the most and get the most number of changes and traffic.

With the goals in mind, we came up with the process for achieving this over a period of 5 months. (Yes, this really has been cooking for a while!) Since none of us had used Cloud DNS before, we wanted to test the waters first. So after some initial testing and trials, this is the process we came up with:

1. Manually create a zone and some records in Cloud DNS to see how it works. Cloud DNS uses a slightly different syntax to specifying records compared to GoDaddy - Cloud DNS always specifies the full name followed by a period (eg. `api.iqzsystems.io.`) compared to GoDaddy which specifies just the host name (eg. api) in the record. So we wanted to be sure of what we needed to do and hence this step.
2. Export the ZONE file from GoDaddy for each domain (A ZONE file contains the full list of records).
3. Prepare Terraform code for creating `iqzsystems.io` domain records in Cloud DNS - we had to manually key in the record information from the ZONE file exported in the previous step.
4. Apply the Terraform code to create the records - we already had the pipeline for this established as part of our infrastructure code for managing our cloud infrastructure. Note that at this point, traffic is still going to be served by GoDaddy. We are merely creating the records at Cloud DNS side.
5. Verify the created records manually at Cloud DNS side.
6. Update the name server information at GoDaddy's side to point to Cloud DNS name servers to switch traffic during IST hours.
7. Validate all records using [dig](https://www.cyberciti.biz/faq/linux-unix-dig-command-examples-usage-syntax/).
8. Repeat the steps for other domains.

Once we established the process, we proceeded to put them in action.

## Timeline

- **March 4th, 2024** - We started the process - but couldn't progress much except creating the zones for `iqzsystems.io` and `iqzapps.com` owing to time constraints with other work.

```hcl
resource "google_dns_managed_zone" "iqzsystems_io" {
  name    = "iqzsystems-io"
  project = data.google_project.iqz_apps.project_id
  dns_name    = "iqzsystems.io."
  description = "Domain name for all internally built services at IQZ Systems."
  labels      = {}
  visibility = "public"
}
```

- **May 17th, 2024** - We completed the full configuration for `iqzsystems.io`. We encountered some issues configuring SRV records mostly due to the syntax variations. [Google's excellent documentation](https://cloud.google.com/dns/docs/records#record_type) came through and helped us solve it all. At this point, we didn't cut traffic over to Cloud DNS yet.

```yaml
# iqzsystems.io.dns.yaml
a:
  "":
    rrdatas:
      - 216.239.32.21
      - 216.239.34.21
      - 216.239.36.21
      - 216.239.38.21
    ttl: 3600
```

```hcl
locals {
  iqzsystems_io_a     = yamldecode(file("./iqzsystems.io.dns.yaml"))["a"]
}

resource "google_dns_record_set" "iqzsystems_io_a" {
  for_each = local.iqzsystems_io_a

  name         = "${each.key}${each.key == "" ? "" : "."}${google_dns_managed_zone.iqzsystems_io.dns_name}"
  project      = data.google_project.iqz_apps.project_id
  managed_zone = google_dns_managed_zone.iqzsystems_io.name
  type         = "A"
  ttl          = each.value.ttl

  rrdatas = each.value.rrdatas
}
```

- **May 21st, 2024** - We switched the name servers for `iqzsystems.io` on GoDaddy's side to point to Cloud DNS and hoped that everything switched over seamlessly. Thankfully, they did! The switchover took close to 4 hours to reflect on GoDaddy's side and we had to wait to see the results, but it did come through at the end. We did a quick dig test to ensure the records were showing up right.
  - Over the next couple of days, we observed for any issues reported by users. We got none. THE SWITCH WAS A SUCCESS!
- **May 23rd, 2024** - We completed full configuration for `iqzsystems.com` on Cloud DNS. This time over, we had some trouble configuring TXT records. In specific, TXT records with multiple values. Google's documentation on this aspect didn't go much into the details because it was more of a Terraform provider related problem, so we had to dig around a bit. But we figured it out in the end.
  - `iqzsystems.com` is the BIG DEAL. We have our mail servers, device management, active directory, and endpoint security depending on it. We verified and re-verified the records multiple times.

```yaml
txt:
  "":
    rrdatas:
      - "XXQ-XXA-XXX"
      - "google-site-verification=xXX_xx009xx000x00x00x00000"
      - "MS=543832498734927984"
      - '"v=spf1 include:spf.protection.outlook.com include:_spf.google.com include:_spf.elasticemail.com -all"'
      - '"v=verifydomain MS=2131231"'
    ttl: 3600
```

- **May 24th, 2024** - We switched the name servers for `iqzsystems.com` in GoDaddy's side. Thankfully, this time it took less than an hour on GoDaddy's side to switch. A quick `dig` test later, we verified all domain access, did multiple mail sending and receiving tests, and waited to see if we got any error reports. WE GOT NONE!
  - Now that we got super confident with the process, we went ahead and configured `iqzapps.com` and `iqzplus.com` on the same day and switched the name servers on Namecheap's side. It also helped that these domains were slightly on the lower priority scale compared to the other two.
  - Namecheap's UI is much cleaner than GoDaddy but it didn't let us export a ZONE file, so we had to configure the domain records by manually copy pasting the records.

## Aftermath

Today, after a week of all the madness, we can confidently say that we've had a successful switch over to Cloud DNS. The domains resolve just a teeny bit faster and doesn't have an annoying 100ms lag like it used to at odd hours.

Cloud DNS comes [with a cost](https://cloud.google.com/dns/pricing). From our rough calculation, we estimate it would come around USD 5.00 every month combined. But the benefits it brings are huge.

Requests to update DNS can be handled by our DevOps team without waiting on me (we still have an approval gate to ensure everything goes through a review). We can also automate DNS updates and more importantly, certificate updates for those pesky Java based applications which use a keystore to store the certs.

It's just so much more convenient!
