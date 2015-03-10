
create_user:
  event.fire_master:
    - name: mail/user/create
    - data:
      username: testing
      email: testing@in.ep3.at
      aliases:
        - testing@ep3.at
        - whatever@ep3.at


