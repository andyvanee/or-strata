OPENRESTY_VERSION=1.5.11.1
OPENRESTY=ngx_openresty-$(OPENRESTY_VERSION)
OPENRESTY_URL=http://openresty.org/download/$(OPENRESTY).tar.gz
OPENRESTY_CONFIG_OPTS=--with-luajit
OPENRESTY_PCRE_OPTS=--with-cc-opt="-I/usr/local/include" --with-ld-opt="-L/usr/local/lib"
PORT=8080

server_path=$(abspath ./server)

conf_path=$(server_path)/nginx/conf/nginx.conf
html_path=$(server_path)/nginx/html
clean_dirs=./build ./server

default: run

clean:
	rm -rf $(clean_dirs)

# always create symlinks
.PHONY: $(conf_path)

run: $(server_path) $(conf_path) $(html_path)
	@ echo Starting server at http://localhost:$(PORT)
	cd $(server_path)/nginx && ./sbin/nginx

$(conf_path): $(abspath ./source/nginx.conf)
	rm $@ && ln -s $^ $@

$(html_path): $(abspath ./source/html)
	rm -rf $@ && ln -s $^ $@

$(server_path): build/$(OPENRESTY)
	mkdir -p $(@D)
	cd $? && ./configure $(OPENRESTY_CONFIG_OPTS) $(OPENRESTY_PCRE_OPTS) --prefix=$@ && make && make install

build/$(OPENRESTY):
	@mkdir -p $(@D)
	cd $(@D) && curl $(OPENRESTY_URL) | tar -xzf -
