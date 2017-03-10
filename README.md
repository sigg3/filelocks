# filelocks
Simple bash script to compare file locks without using flock. Will hopefully demonstrate that you should not use files for locking (use flock or mkdir).

Output should look like this:

    # Comparing file lock methods (BashFAQ/045) - only 1 should run

    Testing method 1: file locks
    4 instance(s) were executed successfully.

    Testing method 2: dir locks
    1 instance(s) were executed successfully.
    Done.
