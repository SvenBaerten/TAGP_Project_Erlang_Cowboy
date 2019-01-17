PROJECT = tagp_project_cowboy

DEPS = cowboy jiffy
dep_cowboy_commit = 2.5.0
dep_jiffy = git https://github.com/davisp/jiffy master

DEP_PLUGINS = cowboy
include erlang.mk
