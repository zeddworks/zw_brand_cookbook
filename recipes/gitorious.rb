#
# Cookbook Name:: zw_brand
# Recipe:: gitorious
#
# Copyright 2011, ZeddWorks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

gitorious = Chef::EncryptedDataBagItem.load("apps", "gitorious")
zw_brand = Chef::EncryptedDataBagItem.load("env", "zw_brand")

git_user = gitorious["user"]
git_group = gitorious["group"]

file "/tmp/logo.b64" do
  content zw_brand["logo"]
  owner git_user
  group git_group
end

execute "cat /tmp/logo.b64 | base64 -d > /srv/rails/gitorious.zeddworks.com/current/public/img/logo.png" do
  user git_user
  group git_group
end

execute "cat /tmp/logo.b64 | base64 -d > /srv/rails/gitorious.zeddworks.com/current/public/img/external/logo.png" do
  user git_user
  group git_group
end

file "/tmp/logo.b64" do
  action :delete
end

cookbook_file "/srv/rails/gitorious.zeddworks.com/current/zw_base_css.patch" do
  source "zw_base_css.patch"
  owner git_user
  group git_group
end

cookbook_file "/srv/rails/gitorious.zeddworks.com/current/zw_external_css.patch" do
  source "zw_external_css.patch"
  owner git_user
  group git_group
end

execute "patch -p0 -i zw_base_css.patch" do
  user git_user
  group git_group
  cwd "/srv/rails/gitorious.zeddworks.com/current"
  not_if "sed -n '304p' /srv/rails/gitorious.zeddworks.com/current/public/stylesheets/base.css | grep 'padding: 0px 0 0 0px;'"
end

execute "patch -p0 -i zw_external_css.patch" do
  user git_user
  group git_group
  cwd "/srv/rails/gitorious.zeddworks.com/current"
  not_if "sed -n '66p' /srv/rails/gitorious.zeddworks.com/current/public/stylesheets/external.css | grep 'width: 100px;'"
end

file "/srv/rails/gitorious.zeddworks.com/current/public/stylesheets/all.css" do
  action :delete
end
