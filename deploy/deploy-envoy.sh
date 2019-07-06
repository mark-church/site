
#Starts the first hugo server
docker run -it --rm --network envoy-net  --name hugo-server-1 -v $(pwd):/site devopsdays/docker-hugo-server hugo --renderToDisk=true --watch=true --bind="0.0.0.0" --baseURL="${VIRTUAL_HOST}" server /site

#Starts the second hugo server
docker run -it --rm --network envoy-net  --name hugo-server-2 -v $(pwd):/site devopsdays/docker-hugo-server hugo --renderToDisk=true --watch=true --bind="0.0.0.0" --baseURL="${VIRTUAL_HOST}" server /site

#Starts the envoy proxy
docker run -v $(pwd)/envoy.json:/etc/envoy/envoy.json -it --rm --network envoy-net --name envoy -p 8001:8001 -p 80:80 envoyproxy/envoy:v1.10.0 envoy -c /etc/envoy/envoy.json

docker run -v /envoy.json:/etc/envoy/envoy.json -v /var/log/envoy.log:/var/log/envoy.log -itd --rm --network host --name envoy envoyproxy/envoy:v1.10.0 envoy -c /etc/envoy/envoy.json

hugo server --bind "0.0.0.0" -p 81 -b "markchur.ch"

hugo server --bind "0.0.0.0" -p 81


hugo -b "http://markchur.ch" 


