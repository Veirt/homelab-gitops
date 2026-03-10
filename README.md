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
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/memos.svg" width="32" /></td>
        <td>Memos</td>
        <td>Lightweight note-taking app.</td>
    </tr>
    <tr>
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/appflowy.svg" width="32" /></td>
        <td>AppFlowy</td>
        <td>Open-source alternative to Notion.</td>
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
        <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/focalboard.svg" width="32" /></td>
        <td>Focalboard</td>
        <td>Open-source project management and collaboration platform.</td>
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
         <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/adguard-home.svg" width="32" /></td>
         <td>AdGuard Home</td>
         <td>DNS-level ad and tracker blocker for your entire network.</td>
     </tr>
     <tr>
         <td><img src="https://cloudnative-pg.io/img/logo.svg" width="32" /></td>
        <td>CloudNativePG</td>
        <td>Cloud-native [PostgreSQL operator](https://github.com/cloudnative-pg/cloudnative-pg) for Kubernetes.</td>
    </tr>

 </table>
 
 <h2>📊 Monitoring</h2>
 <table>
     <tr>
         <th></th>
         <th>Name</th>
         <th>Description</th>
     </tr>
     <tr>
         <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/grafana.svg" width="32" /></td>
         <td>Grafana</td>
         <td>Visualization and analytics platform for metrics, logs, and traces.</td>
     </tr>
     <tr>
         <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/prometheus.svg" width="32" /></td>
         <td>Prometheus</td>
         <td>Metrics collection and alerting toolkit.</td>
     </tr>
     <tr>
         <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/loki.svg" width="32" /></td>
         <td>Loki</td>
         <td>Log aggregation system optimized for Kubernetes.</td>
     </tr>
     <tr>
         <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/alloy.svg" width="32" /></td>
         <td>Alloy</td>
         <td>OpenTelemetry Collector for collecting logs, metrics, and traces.</td>
     </tr>
     <tr>
         <td><img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/victoriametrics.svg" width="32" /></td>
         <td>Victoria Metrics</td>
         <td>High-performance metrics storage and querying.</td>
     </tr>
 </table>
