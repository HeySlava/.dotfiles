### nvim
Download [latest neovim release](https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz)

```bash
# maybe mkdir /opt
tar xzf nvim-linux64.tar.gz -C /opt/
sudo ln -s /opt/nvim-linux64/bin /usr/local/bin/nvim
```

In case I want to migrate back to packer

```
{'neovim/nvim-lspconfig', commit = 'f0c6ccf'},
```
