# URL allowlist {#url-allowlist}

Several features let a user or an administrator give the catalogue a URL, which the catalogue then fetches itself: harvesters, thesaurus downloads, DOI servers, map servers, attachments uploaded from a URL, xlinks resolved out of a record, images fetched while a PDF is produced, and the link checker.

Left unrestricted, those features can be used to make the catalogue reach an address it should not — a service on the machine itself, another host inside the network, or a cloud provider's metadata endpoint. The URL allowlist restricts them to addresses you list.

## Switching it on

Checks are **off by default**, and an upgraded catalogue behaves exactly as it did before until you turn them on. When they are off, no URL is checked.

In *Admin console > Settings*, the *URL allowlist* section has three settings:

-   **Enable URL checks**: when on, the catalogue may only use URLs matching one of the rules. With no rule at all, every URL is refused, so add the rules first.
-   **Audit mode**: refuses nothing, and logs what would have been refused. This is how you find out what a set of rules would break before enforcing it.
-   **Allow internal addresses**: loopback, link-local and private addresses (`127.0.0.1`, `169.254.169.254`, `10.0.0.0/8`, `::1` and the like) are refused **even when a rule matches them**, because a broad rule must not open a path to a service inside the network. Turn this on only for a deployment that legitimately uses internal hosts, such as a harvester reading from an intranet server.

The rules themselves are managed in *Admin console > Settings > URL allowlist*.

!!! note

    The catalogue is always allowed to reach itself, whatever the rules say. The address comes from the catalogue's own base URL, so it follows the catalogue if it moves. A base URL on a literal internal address still needs *Allow internal addresses*.

## Writing a rule

A rule is a pattern of the form `[scheme://]host[:port][/path]`, where `*` matches any sequence of characters:

| Pattern | Matches |
|---------|---------|
| `https://registry.example.org` | that host over https, any port, any path |
| `https://*.example.org/thesauri` | any sub-domain of example.org, paths under `/thesauri` |
| `*.example.org` | any sub-domain, over any allowed scheme |
| `*` | any host — the least restrictive rule you can write |

The pattern is matched against the URL after it has been parsed and normalised, not against the text a user typed. The host is lower-cased and converted to punycode, any user information is dropped, the default port is made explicit and the path is normalised. So:

-   `https://registry.example.org@evil.org/` is matched on `evil.org`, not on the allowed host.
-   `*.example.org` covers `a.example.org` and `a.b.example.org`, but neither `evil-example.org` nor `example.org` itself — add a second rule for the apex when you need it.
-   A path is a prefix that stops on a segment boundary, so `/thesauri` allows `/thesauri` and `/thesauri/rdf` but not `/thesauri-private`.
-   Only `http` and `https` are allowed, whatever the rules say: `file:`, `jar:` and `ftp:` URLs are refused once the checks are on.

Every redirect is checked too, so an allowed host that answers with a redirect to a host you have not listed does not get through.

### Trying a URL

The *Try a URL* form reports what the current rules decide for an address, and which rule decided it. It always reports the real verdict, even in audit mode, and it is the quickest way to confirm a rule does what you meant.

## Restricting one feature differently

Each feature either uses the catalogue rules or has rules of its own. In the *Features* panel:

| Mode | Behaviour |
|------|-----------|
| Use the catalogue rules | The default. A feature nobody has configured is still restricted, and a feature added in a later version is restricted without you doing anything. |
| Catalogue rules and its own | For a feature that needs one more host than the rest of the catalogue. |
| Only its own rules | For a feature that has to be held to less than the catalogue is allowed in general. |
| Not checked | No check at all for that feature. Explicit, logged, and a last resort. |

A rule is written either for the catalogue as a whole or for one feature. A rule written for a feature only applies where that feature extends or overrides the catalogue rules. The *Rules in effect* panel shows what a given feature ends up evaluating, once its mode has been applied.

## Before you enable it

The *Addresses that would be refused* panel checks the harvesters, map servers and DOI servers already configured in this catalogue against the current rules. It does not depend on the checks being switched on, so look at it first: anything listed there stops working the moment you enable them.

Together with audit mode, that is the whole procedure:

1.  Add the rules you believe you need.
2.  Read *Addresses that would be refused* and fix what is listed.
3.  Turn on audit mode and use the catalogue normally for a while; refusals are logged, nothing is blocked.
4.  Turn audit mode off and the checks on.

## Upgrading from the thesaurus allowlist

A catalogue that used the thesaurus URL allowlist of 4.4.x has its patterns carried over on the first start: they become rules of the thesaurus feature, that feature is held to those rules alone, and the checks are switched on so the protection is not lost.

Everything else keeps working exactly as before, through a migrated rule named `everything` that allows any host, and the link checker feature is left unchecked because it used to follow whatever records point at, over ftp as well as http. **Narrow or remove the `everything` rule** to restrict the rest of the catalogue. What was migrated is written to the log at start-up.

## Reporting stored online resources

Online resource URLs stored in records are reported rather than refused: the *URL allowlist* validation rule flags an address the catalogue is not allowed to use, and the record still saves. Records arrive by harvesting, import and API as well as from the editor, and refusing them on the way in would turn one unlisted partner host into failed harvests.

The rule is a warning by default. An administrator who wants publication gated on it can raise it to an error in *Admin console > Metadata and templates > Validation*, where a record failing it becomes invalid. Nothing is reported while the URL checks are switched off.

## What is not checked

Addresses that come from deployment configuration rather than from anything a user supplies are not checked: the OpenID Connect provider, Microsoft Graph, cloud storage, the Elasticsearch endpoint. Refusing those would break signing in or starting up rather than prevent a request nobody asked for.

The check is made on the host name in the URL. A name that resolves to an internal address only at the moment the connection is made is not caught.

The `proxy.excludeHosts` and `proxy.securityMode` settings of the client-side proxy are separate, and still apply as before.
