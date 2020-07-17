Requires patches to fix error 
```
AttributeError: /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1: undefined symbol: OPENSSL_no_config
```

https://github.com/saltstack/salt/pull/37772/files

Patch the file located in `nano /usr/lib/python2.7/dist-packages/salt/utils/rsax931.py`