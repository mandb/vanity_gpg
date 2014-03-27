vanity_gpg
==========

Threaded vanity gpg key editor! Just choose your regex strings, it will generate keys until it finds a match, then save it!



usage:

    Edit vanitygen.pl, 
    choose your desired key_len, key_name, key_pass, key_email and thread_count(1 per logical core will typically saturate)
    
    choose your desired @needles - these will be parsed as independent regexes on your key (if you wish to match on short key, change the matching in keyThread ie: @matches= ($long_id -> @matches= ($short_id
    
    on an 8 core e5 Xeon it is roughly 5 2048 bit RSA keys/s
    
    Once a key is found, a <key_id>.sec.gpg, and <key_id>.pub.gpg will be generated in the working folder - you can remove any other extraneous .sec and .pub files created during the process (one per thread).
    
    Based off of Mayeu (https://gist.github.com/Mayeu/8575504)'s "Dirty Dirty Dirty" implementation.
    
    
