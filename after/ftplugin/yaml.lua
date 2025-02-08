if string.find(vim.fn.expand("%"), "compose") then
  vim.bo.filetype = 'yaml.docker-compose'
end
