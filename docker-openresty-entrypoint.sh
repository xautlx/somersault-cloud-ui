#!/bin/bash

if [ "${API_URL_PREFIX_TARGET}" != "" ]; then
  echo "Prepare replace from ${API_URL_PREFIX_SOURCE} to ${API_URL_PREFIX_TARGET} for all *.js ..."
  find /usr/local/openresty/nginx/html/admin/assets -type f -iname "*.js" \
   -exec sed -i "s#${API_URL_PREFIX_SOURCE}#${API_URL_PREFIX_TARGET}#" {} \;
fi

echo "Startup openresty..."
/usr/bin/openresty -g "daemon off;"