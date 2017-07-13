" ==============================================================
" Description:  Vim plugin for working with Rails I18n
" Author:       Alexander Skachko <alexander.skachko@gmail.com>
" Homepage:     https://github.com/lucerion/vim-i18n-rails
" Version:      0.2.0 (2017-07-14)
" Licence:      BSD-3-Clause
" ==============================================================

let s:positions = {
  \ 'top': 'leftabove split',
  \ 'bottom': 'rightbelow split',
  \ 'left': 'vertical leftabove split',
  \ 'right': 'vertical rightbelow split',
  \ 'tab': 'tab split'
  \ }
let s:default_position = 'tab'
let s:default_split = s:positions[s:default_position]

let s:errors = {
  \ 'dir': "Dir '{variable}' does not exists!",
  \ 'file': "File '{variable}' does not exists!",
  \ 'translation': "Translation '{variable}' not found!"
  \ }

func! i18n_rails#translation(selection_length)
  if !isdirectory(s:locale_directory())
    call s:error('dir', s:locale_directory()) | return
  endif

  let l:locale_file = s:locale_file()
  if !filereadable(l:locale_file)
    call s:error('file', l:locale_file) | return
  endif

  let l:locale_key = s:locale_key(a:selection_length, l:locale_file)
  let l:translation = s:translation(l:locale_file, l:locale_key)

  if s:is_empty(l:translation)
    call s:error('translation', l:locale_key)
  else
    echo l:translation
  endif
endfunc

func! i18n_rails#all_translations(selection_length)
  if !isdirectory(s:locale_directory())
    call s:error('dir', s:locale_directory()) | return
  endif

  let l:locale_key = s:locale_key(a:selection_length)
  let l:translations = s:collect_translations(l:locale_key)

  if s:is_empty(l:translations)
    call s:error('translation', l:locale_key)
  else
    call setloclist(0, l:translations, 'r')
    silent! exec 'lopen'
    call s:apply_default_mappings()
  endif
endfunc

func! i18n_rails#goto_definition(selection_length, ...)
  if !isdirectory(s:locale_directory())
    call s:error('dir', s:locale_directory()) | return
  endif

  let l:locale_file = s:locale_file()
  if !filereadable(l:locale_file)
    call s:error('file', l:locale_file) | return
  endif

  let l:locale_key = s:locale_key(a:selection_length, l:locale_file)
  let l:line_number = s:line_number(l:locale_file, l:locale_key)

  if s:is_empty(l:line_number)
    call s:error('translation', l:locale_key)
  else
    call s:open_locale(l:locale_file, a:000)
    call s:goto_line(l:line_number)
  endif
endfunc

func! s:translation(locale_file, locale_key)
  let l:path = split(a:locale_key, '\.')
  let l:translation = ''
ruby << EOF
  require 'yaml'

  locale_hash = YAML.load_file(VIM.evaluate('a:locale_file'))
  locale_path = VIM.evaluate('l:path')
  translation = locale_path.inject(locale_hash) do |hash, key|
    hash = hash.fetch(key, {})
  end
  if translation.is_a?(String)
    VIM.command("let l:translation = '#{translation}'")
  end
EOF
  return l:translation
endfunc

func! s:line_number(locale_file, locale_key)
  let l:path = split(a:locale_key, '\.')
  let l:lines = readfile(a:locale_file)
  let l:line_number = 0
  let l:current_line_number = 0

  if s:is_empty(l:path)
    return
  endif

  for l:line in l:lines
    let l:current_line_number += 1

    if l:line =~ '^\s*' . l:path[0] . ':'
      let l:line_number = l:current_line_number
      let l:path = l:path[1:]
    endif

    if s:is_empty(l:path)
      break
    endif
  endfor

  if s:is_empty(l:path)
    return l:line_number
  endif
endfunc

func! s:collect_translations(locale_key)
  let l:translations = []
  let l:locale_files = split(globpath(s:locale_directory(), '*'), '\n')

  for l:locale_file in l:locale_files
    let l:locale_key  = s:full_locale_key(l:locale_file, a:locale_key)
    let l:line_number = s:line_number(l:locale_file, l:locale_key)
    let l:translation = s:translation(l:locale_file, l:locale_key)

    if !s:is_empty(l:translation)
      call add(l:translations, {
      \ 'filename': l:locale_file,
      \ 'lnum': l:line_number,
      \ 'text': l:translation
      \ })
    endif
  endfor

  return l:translations
endfunc

func! s:locale_directory()
  return split(s:current_path(), '/app')[0] . '/config/locales/'
endfunc

func! s:locale_file()
  let l:locale_file = s:default_locale_file()

  if s:is_empty(l:locale_file)
    let l:locale_file = s:ask_locale_file()
  endif

  return l:locale_file
endfunc

func! s:default_locale_file()
  if !s:is_empty(g:i18n_rails_default_locale_file)
    return s:locale_directory() . g:i18n_rails_default_locale_file
  endif
endfunc

func! s:ask_locale_file()
  let l:locale_directory = s:locale_directory()
  let l:current_path = s:current_path()

  exec 'lcd ' . l:locale_directory
  let l:locale_file = input('File: ', l:locale_directory, 'file')
  exec 'lcd ' . l:current_path
  redraw

  return l:locale_file
endfunc

func! s:locale_key(selection_length, ...)
  let l:locale_file = get(a:000, 0, '')

  if s:is_empty(a:selection_length)
    if s:is_empty(l:locale_file)
      return s:ask_locale_key()
    else
      let l:locale = s:locale(l:locale_file) . '.'
      return s:ask_locale_key(l:locale)
    endif
  else
    if s:is_empty(l:locale_file)
      return s:selection()
    else
      return s:full_locale_key(l:locale_file, s:selection())
    endif
  end
endfunc

func! s:ask_locale_key(...)
  let l:text = get(a:000, 0, '')
  let l:locale_key = input('Locale key: ', l:text)
  redraw
  return l:locale_key
endfunc

func! s:full_locale_key(locale_file, locale_key)
  return s:locale(a:locale_file) . '.' . a:locale_key
endfunc

func! s:selection()
  try
    let l:previous_register_value = @z
    normal! gv"zy
    return @z
  finally
    let @z = l:previous_register_value
  endtry
endfunc

func! s:locale(locale_file)
  return fnamemodify(a:locale_file, ':t:r')
endfunc

func! s:goto_line(line_number)
  call cursor(a:line_number, 0)
  normal! _
  silent! normal! zO
endfunc

func! s:open_locale(locale_file, position)
  let l:position = empty(a:position) ? s:default_position : a:position[0]
  let l:split = get(s:positions, l:position, s:default_split)
  silent exec l:split . a:locale_file
endfunc

func! s:current_path()
  return expand('%:p:h')
endfunc

func! s:apply_default_mappings()
  if g:i18n_rails_use_default_mappings
    nnoremap <buffer> <silent> q :lclose<CR>
    for mapping in items(g:i18n_rails_mappings)
      exec 'nnoremap <buffer> <silent>' . ' ' .
        \ get(mapping, 0) . ' ' . get(mapping, 1)
    endfor

    if g:i18n_rails_translations_autopreview
      nnoremap <buffer> <silent> j j<CR><C-W><C-W>
      nnoremap <buffer> <silent> k k<CR><C-W><C-W>
    endif
  end
endfunc

func! s:is_empty(value)
  let l:value = a:value

  if type(l:value) == type(1)
    return l:value <= 0
  endif

  if type(l:value) == type('string')
    let l:value = substitute(l:value, '\s', '', 'g')
    let l:value = substitute(l:value, '\t', '', 'g')
  endif

  return empty(l:value)
endfunc

func! s:error(key, variable)
  let l:message = substitute(s:errors[a:key], '{variable}', a:variable, '')
  echohl ErrorMsg | echomsg l:message | echohl None
endfunc
