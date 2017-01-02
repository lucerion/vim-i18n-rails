" ==============================================================
" Description:  Vim plugin for working with Rails I18n
" Author:       Alexander Skachko <alexander.skachko@gmail.com>
" Homepage:     https://github.com/lucerion/vim-i18n-rails
" Version:      0.1.0 (2017-01-02)
" Licence:      BSD-3-Clause
" ==============================================================

if exists('g:loaded_i18n_rails') || &compatible || v:version < 700 ||
    \ !has('ruby')
  finish
endif

if !exists('g:i18n_rails_default_locale_file')
  let g:i18n_rails_default_locale_file = ''
endif

if !exists('g:I18n_rails_default_position')
  let g:I18n_rails_default_position = 'tab'
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

func! s:autocompletion(A, L, C)
  return ['current', 'top', 'bottom', 'left', 'right', 'tab']
endfunc

func! s:init_commands()
  comm! -nargs=0 -range I18nTranslation
    \ call i18n_rails#translation(<count>)
  comm! -nargs=0 -range I18nAllTranslations
    \ call i18n_rails#all_translations(<count>)
  comm! -nargs=? -range -complete=customlist,s:autocompletion I18nGoToDefinition
    \ call i18n_rails#goto_definition(<count>, <f-args>)
endfunc

augroup I18n_rails_commands
  autocmd!
  autocmd FileType ruby,eruby,haml,slim,javascript,coffee call s:init_commands()
augroup END

let g:loaded_i18n_rails = 1
