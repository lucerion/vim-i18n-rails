" ==============================================================
" Description:  Vim plugin for Rails I18n
" Author:       Alexander Skachko <alexander.skachko@gmail.com>
" Homepage:     https://github.com/lucerion/vim-i18n-rails
" Version:      0.2.0 (2017-07-14)
" Licence:      BSD-3-Clause
" ==============================================================

let s:errors_messages = {
  \ 'directory':   "Directory '{directory}' does not exists!",
  \ 'file':        "File '{file}' does not exists!",
  \ 'locale_key':  'Key can not be empty!',
  \ 'translation': "Translation '{locale_key}' not found!"
  \ }

func! i18n_rails#translation(has_selection) abort
  let l:locale_directory = s:locale_directory()
  if !isdirectory(l:locale_directory)
    call s:show_error(s:errors_messages.directory, { 'directory': l:locale_directory }) | return
  endif

  let l:locale_file = s:locale_file()
  if !filereadable(l:locale_file)
    call s:show_error(s:errors_messages.file, { 'file': l:locale_file }) | return
  endif

  let l:locale_key = s:locale_key(a:has_selection)
  if s:is_empty(l:locale_key)
    call s:show_error(s:errors_messages.locale_key) | return
  endif

  let l:translation = s:translation(l:locale_file, l:locale_key)
  if s:is_empty(l:translation)
    call s:show_error(s:errors_messages.translation, { 'locale_key': l:locale_key }) | return
  endif

  echo l:translation
endfunc

func! i18n_rails#translations(has_selection) abort
  let l:locale_directory = s:locale_directory()
  if !isdirectory(l:locale_directory)
    call s:show_error(s:errors_messages.directory, { 'directory': l:locale_directory }) | return
  endif

  let l:locale_key = s:locale_key(a:has_selection)
  if s:is_empty(l:locale_key)
    call s:show_error(s:errors_messages.locale_key) | return
  endif

  let l:translations = s:translations(l:locale_key)
  if s:is_empty(l:translations)
    call s:show_error(s:errors_messages.translation, { 'locale_key': l:locale_key }) | return
  end

  call setloclist(0, l:translations, 'r')
  silent! exec 'lopen'
  call s:apply_mappings()
endfunc

func! i18n_rails#open(has_selection, mods) abort
  let l:locale_directory = s:locale_directory()
  if !isdirectory(l:locale_directory)
    call s:show_error(s:errors_messages.directory, { 'directory': l:locale_directory }) | return
  endif

  let l:locale_file = s:locale_file()
  if !filereadable(l:locale_file)
    call s:show_error(s:errors_messages.file, { 'file': l:locale_file }) | return
  endif

  let l:locale_key = s:locale_key(a:has_selection)
  if s:is_empty(l:locale_key)
    call s:show_error(s:errors_messages.locale_key) | return
  endif

  let l:line_number = s:line_number(l:locale_file, l:locale_key)
  if s:is_empty(l:line_number)
    call s:show_error(s:errors_messages.translation, { 'locale_key': l:locale_key }) | return
  endif

  call s:open_locale(l:locale_file, a:mods)
  call s:goto_line(l:line_number)
endfunc

func! s:translation(locale_file, locale_key) abort
  let l:locale_key = s:full_locale_key(a:locale_file, a:locale_key)
  let l:path = split(l:locale_key, '\.')
  let l:translation = s:parse_yaml(a:locale_file)

  while !s:is_empty(l:path)
    if type(l:translation) != type({})
      break
    endif

    let l:node = get(l:translation, l:path[0], {})
    if s:is_empty(l:node)
      break
    else
      let l:translation = l:node
      let l:path = l:path[1:]
    endif
  endwhile

  if s:is_empty(l:path)
    return l:translation
  endif
endfunc

func! s:translations(locale_key) abort
  let l:translations = []
  let l:locale_files = split(globpath(s:locale_directory(), '*'), '\n')

  for l:locale_file in l:locale_files
    let l:line_number = s:line_number(l:locale_file, a:locale_key)
    let l:translation = s:translation(l:locale_file, a:locale_key)

    if !s:is_empty(l:translation)
      call add(l:translations, { 'filename': l:locale_file, 'lnum': l:line_number, 'text': l:translation })
    endif
  endfor

  return l:translations
endfunc

func! s:line_number(locale_file, locale_key) abort
  let l:locale_key = s:full_locale_key(a:locale_file, a:locale_key)
  let l:path = split(l:locale_key, '\.')
  let l:lines = readfile(a:locale_file)
  let l:line_number = 0
  let l:current_line_number = 0

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

func! s:locale_directory() abort
  return split(s:current_path(), '/app')[0] . '/config/locales/'
endfunc

func! s:current_path()
  return expand('%:p:h')
endfunc

func! s:locale_file() abort
  let l:locale_directory = s:locale_directory()
  let l:locale_file = ''

  if !s:is_empty(g:i18n_rails_default_locale)
    let l:locale_file = l:locale_directory . g:i18n_rails_default_locale . '.yml'
  endif

  if s:is_empty(l:locale_file)
    let l:current_path = s:current_path()
    exec 'lcd ' . l:locale_directory
    let l:locale_file = input('File: ', l:locale_directory, 'file')
    exec 'lcd ' . l:current_path
    redraw
  endif

  return l:locale_file
endfunc

func! s:locale_key(has_selection) abort
  if s:is_empty(a:has_selection)
    let l:locale_key = input('Locale key: ')
    redraw
    return l:locale_key
  end

  return s:selection()
endfunc

func! s:full_locale_key(locale_file, locale_key) abort
  return fnamemodify(a:locale_file, ':t:r') . '.' . a:locale_key
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

func! s:open_locale(locale_file, mods) abort
  silent exec a:mods . ' split ' . a:locale_file
endfunc

func! s:goto_line(line_number)
  call cursor(a:line_number, 0)
  normal! _
  silent! normal! zO
endfunc

func! s:parse_yaml(path) abort
  let l:result = {}
ruby << EOF
  require 'yaml'
  require 'json'

  file_path = VIM.evaluate('a:path')
  yaml = YAML.load_file(file_path)
  VIM.command("let l:result = #{yaml.to_json}")
EOF
  return l:result
endfunc

func! s:apply_mappings() abort
  if g:i18n_rails_use_default_mappings
    nnoremap <buffer> <silent> q :lclose<CR>
    for l:mapping in items(g:i18n_rails_mappings)
      exec 'nnoremap <buffer> <silent>' . ' ' . get(l:mapping, 0) . ' ' . get(l:mapping, 1)
    endfor

    if g:i18n_rails_translations_autopreview
      nnoremap <buffer> <silent> j j<CR><C-W><C-W>
      nnoremap <buffer> <silent> k k<CR><C-W><C-W>
    endif
  end
endfunc

func! s:show_error(message, ...) abort
  let l:message = a:message
  if !s:is_empty(a:000)
    for l:variable in keys(a:1)
      let l:message = substitute(l:message, '{'.l:variable.'}', a:1[l:variable], 'g')
    endfor
  endif
  echohl ErrorMsg | echomsg l:message | echohl None
endfunc

func! s:is_empty(value) abort
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
