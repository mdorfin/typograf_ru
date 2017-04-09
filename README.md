[![Build Status](https://travis-ci.org/mdorfin/typograf_ru.svg?branch=master)](https://travis-ci.org/mdorfin/typograf_ru)

typograf_ru
===========

This gem changes user's input through typography rules of http://typograf.ru.
It is designed for ActiveRecord. 

Installation
============

Just add the following line to your Gemfile as usual.

```ruby
  gem 'typograf_ru'
```

and install it

```bash
  $ bundle install
```

Ussage
======

```ruby
  class Post < ActiveRecord::Base
    typografy :content
  end 
```

It will format the content before save.

The ```typografy``` method supports two options:

* ```:if``` expects a ```Proc``` returning ```true``` or ```false```. 
* ```:no_check``` if true it will always hit the service before save.

You can disable the gem in tests: 

```ruby
  describe Post do 	
    before { Post.disable_typografy! }
    # ...
  end
```
