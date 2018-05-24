" ==============================================================
" Description:  Vim plugin for Rails I18n
" Author:       Alexander Skachko <alexander.skachko@gmail.com>
" Homepage:     https://github.com/lucerion/vim-i18n-rails
" Version:      0.2.0 (2017-07-14)
" Licence:      BSD-3-Clause
" ==============================================================

if exists('g:loaded_i18n_rails') || &compatible || v:version < 700 || !has('ruby')
  finish
endif
let g:loaded_i18n_rails = 1

if !exists('g:i18n_rails_default_locale')
  let g:i18n_rails_default_locale = ''
endif

if !exists('g:i18n_rails_default_position')
  let g:i18n_rails_default_position = 'tab'
endif

let s:default_mappings = {
  \ 'o':  '<CR>',
  \ 'O':  '<CR><C-W>p<C-W>c',
  \ 'go': '<CR><C-W>p',
  \ 't':  '<C-W><CR><C-W>T',
  \ 'T':  '<C-W><CR><C-W>TgT<C-W>j',
  \ 'h':  '<C-W><CR><C-W>K',
  \ 'H':  '<C-W><CR><C-W>K<C-W>b',
  \ 'v':  '<C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t',
  \ 'gv': '<C-W><CR><C-W>H<C-W>b<C-W>J'
  \ }

if exists('g:i18n_rails_mappings')
  let g:i18n_rails_mappings = extend(s:default_mappings, g:i18n_rails_mappings)
else
  let g:i18n_rails_mappings = s:default_mappings
endif

if !exists('g:i18n_rails_use_default_mappings')
  let g:i18n_rails_use_default_mappings = 1
endif

if !exists('g:i18n_rails_translations_autopreview')
  let g:i18n_rails_translations_autopreview = 0
endif

func! s:autocompletion(input, command_line, cursor_position) abort
  let l:positions = ['current', 'top', 'bottom', 'left', 'right', 'tab']
  return filter(l:positions, 'v:val =~ a:input')
endfunc

comm! -nargs=0 -range I18nTranslation call i18n_rails#translation(<count>)
comm! -nargs=0 -range I18nAllTranslations call i18n_rails#translations(<count>)
comm! -nargs=? -range -complete=customlist,s:autocompletion I18nOpen call i18n_rails#open(<count>, <f-args>)
