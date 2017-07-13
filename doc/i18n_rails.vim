*vim-i18n-rails.txt*    Vim plugin for working with Rails I18n

Author:               Alexander Skachko <alexander.skachko@gmail.com>
Homepage:             https://github.com/lucerion/vim-i18n-rails
Version:              0.1.0 (2017-01-02)
Licence:              BSD-3-Clause (see LICENSE)

===============================================================================
CONTENTS                                                       *vim-i18n-rails*

Install                                                |vim-i18n-rails-install|
Commands                                              |vim-i18n-rails-commands|
Options                                                |vim-i18n-rails-options|
Changelog                                            |vim-i18n-rails-changelog|
License                                                |vim-i18n-rails-license|

===============================================================================
INSTALL                                                *vim-i18n-rails-install*

Vundle                                https://github.com/VundleVim/Vundle.vim
>
    Plugin 'lucerion/vim-i18n-rails'
<
Pathogen                                https://github.com/tpope/vim-pathogen
>
    cd ~/.vim/bundle
    git clone https://github.com/lucerion/vim-i18n-rails
<
NeoBundle                             https://github.com/Shougo/neobundle.vim
>
    NeoBundle 'lucerion/vim-i18n-rails'
<
vim-plug                                 https://github.com/junegunn/vim-plug
>
    Plug 'lucerion/vim-i18n-rails'
<
Manual
>
    git clone https://github.com/lucerion/vim-i18n-rails
<
    copy all of the files into your ~/.vim directory

===============================================================================
COMMANDS                                              *vim-i18n-rails-commands*

                                                             *:I18nTranslation*

:I18nTranslation                      Show translation.

                                                         *:I18nAllTranslations*

:I18nAllTranslations                  Open quickfix window with translations
                                      by all locales.

                                                          *:I18nGoToDefinition*

:I18nGoToDefinition {position}        Open locale file on line with
                                      translation.
                                      Possible {position} value: 'current',
                                      'top', 'bottom', 'left', 'right', 'tab'

===============================================================================
OPTIONS                                                *vim-i18n-rails-options*

                                             *g:i18n_rails_default_locale_file*

Default locale file.
Default: ''

                                                *g:I18n_rails_default_position*

Position where locale file will be opened.
Possible value: 'current', 'top', 'bottom', 'left', 'right', 'tab'
Default: 'tab'

                                                        *g:i18n_rails_mappings*

Default mappings for all locales quickfix window.

  o     open file
  O     open file and close the results window
  go    preview file (open file, keeping focus on the results window)
  t     open file in new tab
  T     open file in new tab without moving to it
  h     open file in horizontal split
  H     open file in horizontal split, keeping focus on the results window
  v     open file in vertical split
  gv    open file in vertical split, keeping focus on the results window
  q     close the results window

Default: >
    {
      \ 'o': '<CR>',
      \ 'O': '<CR><C-W>p<C-W>c',
      \ 'go': '<CR><C-W>p',
      \ 't': '<C-W><CR><C-W>T',
      \ 'T': '<C-W><CR><C-W>TgT<C-W>j',
      \ 'h': '<C-W><CR><C-W>K',
      \ 'H': '<C-W><CR><C-W>K<C-W>b',
      \ 'v': '<C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t',
      \ 'gv': '<C-W><CR><C-W>H<C-W>b<C-W>J'
      \ }
<
                                            *g:i18n_rails_use_default_mappings*

Enable/disable default mappings.
Default: 1

                                        *g:i18n_rails_translations_autopreview*

Enable/disable auto preview (open a file on 'j' or 'k' press).
Default: 0

===============================================================================
CHANGELOG                                            *vim-i18n-rails-changelog*

0.2.0 (2017-07-14)~
  Changes
    * code refactoring - use ruby for parsing yaml only
    * rename i18n_rails#goto_definition to i18n_rails#open command
    * rename g:i18n_rails_default_locale_file to g:i18n_rails_default_locale
    * fix g:i18n_rails_default_position usage

0.1.0 (2017-01-02)~
  First release

===============================================================================
LICENSE                                                *vim-i18n-rails-license*

Copyright © 2017, Alexander Skachko
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

===============================================================================
vim:tw=78:ts=4:ft=help:norl:
