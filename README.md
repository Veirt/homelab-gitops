# My Homelab

This repository is where I keep the GitOps configuration for my homelab. I use
it as a place to run the software I build, try out new tools, and automate
parts of my daily life. It is mostly a hobby project, but it also helps me
learn more about DevOps and cloud-native practices in a practical way.

I don't aim for perfection here (seriously). Things will change often as I experiment and
figure out better ways to manage this. This repo works both as
documentation for myself and as something others can look at to learn from. If you
find something useful, feel free to use it in your own projects.

The setup includes a mix of media services, personal productivity tools, and
infrastructure components. Some are for fun, some are for convenience, and
others are just experiments.

Feel free to explore and see how everything is set up. If you have any
questions or suggestions, you can reach out to me on Discord (veirt). If I can help you with something, I
will be happy to do so.

# Installed Apps

<h2>🎬 Media</h2>
<table>
    <tr>
        <th></th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/jellyfin.svg" width="32" /></td>
        <td>Jellyfin</td>
        <td>Media server for streaming movies and TV shows.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/metube.svg" width="32" /></td>
        <td>Metube</td>
        <td>YouTube-DL web UI for downloading videos.</td>
    </tr>
    <tr>
        <td><img src="https://github.com/svenstaro/miniserve/raw/master/data/logo.svg" width="32" /></td>
        <td>Miniserve</td>
        <td>Simple self-hosted file server.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/syncthing.svg" width="32" /></td>
        <td>Syncthing</td>
        <td>Continuous file synchronization between devices.</td>
    </tr>
</table>

<h2>📝 Productivity & Automation</h2>
<table>
    <tr>
        <th></th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/paperless-ngx.svg" width="32" /></td>
        <td>Paperless-NGX</td>
        <td>Document management system for organizing and searching PDFs.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/memos.png" width="32" /></td>
        <td>Memos</td>
        <td>Lightweight note-taking app.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/n8n.svg" width="32" /></td>
        <td>n8n</td>
        <td>Workflow automation tool for connecting apps and services.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/ntfy.svg" width="32" /></td>
        <td>ntfy</td>
        <td>Push notification service for sending messages to devices.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/commafeed.svg" width="32" /></td>
        <td>CommaFeed</td>
        <td>Self-hosted RSS reader inspired by Google Reader.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/searxng.png" width="32" /></td>
        <td>Searxng</td>
        <td>Privacy-focused metasearch engine.</td>
    </tr>
    <tr>
        <td><img src="https://raw.githubusercontent.com/Veirt/vesta/refs/heads/master/static/logo-bg.png" width="32" /></td>
        <td>Vesta</td>
        <td>Dashboard for monitoring server services.</td>
    </tr>
    <tr>
        <td><img src="https://i.imgur.com/aCmA6rH.png" width="32" /></td>
        <td>MySpeed</td>
        <td>Automated internet speed test tool.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/vaultwarden.svg" width="32" /></td>
        <td>Vaultwarden</td>
        <td>Password manager compatible with Bitwarden clients.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/wakapi.svg" width="32" /></td>
        <td>Wakapi</td>
        <td>Time-tracking tool for monitoring coding activity.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/hoarder.svg" width="32" /></td>
        <td>Karakeep</td>
        <td>AI-powered bookmarking app for those who love collecting data.</td>
    </tr>
    <tr>
        <td></td>
        <td>Crawl4AI</td>
        <td>Web crawler for collecting data from websites.</td>
    </tr>
    <tr>
        <td><img src="https://media.sys.truenas.net/apps/convertx/icons/icon.png" width="32" /></td>
        <td>ConvertX</td>
        <td>Self-hosted file converter</td>
    </tr>
</table>

<h2>🗄️ Databases</h2>
<table>
    <tr>
        <th></th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/couchdb.svg" width="32" /></td>
        <td>CouchDB</td>
        <td>Distributed JSON document store powering internal apps.</td>
    </tr>
</table>

<h2>⚙️ Infrastructure</h2>
<table>
    <tr>
        <th></th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/cert-manager.svg" width="32" /></td>
        <td>Cert-Manager</td>
        <td>Automated management and issuance of TLS certificates.</td>
    </tr>
    <tr>
        <td><img src="https://external-secrets.io/latest/pictures/eso-round-logo.svg" width="32" /></td>
        <td>External Secrets</td>
        <td>Securely manage secrets from external stores.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/portainer.svg" width="32" /></td>
        <td>Portainer</td>
        <td>A lightweight management UI for Kubernetes.</td>
    </tr>
    <tr>
        <td><img src="https://artifacthub.io/image/720a1019-8159-43e4-9cfd-b4be88b32da3@3x" width="32" /></td>
        <td>Sealed Secrets</td>
        <td>For encrypting secrets that are safe to store in a public Git repository.</td>
    </tr>
    <tr>
        <td></td>
        <td>Zeropod</td>
        <td>Scales down idle Kubernetes workloads to zero.</td>
    </tr>
</table>
