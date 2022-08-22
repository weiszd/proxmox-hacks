# Proxmox hacks
Download CT templates in proxmox terminal:
<BR>
`curl -sL https://github.com/weiszd/proxmox-hacks/raw/main/fav_ct_templates.txt | parallel pveam download local {}`
<BR>or<BR>
`curl -sL https://github.com/weiszd/proxmox-hacks/raw/main/fav_ct_templates.txt | xargs -I{} pveam download local {}`
