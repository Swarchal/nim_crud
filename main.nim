import std/[json, strutils]

import jester
import mustache

import database


let db = createDb()

routes:

  get "/":
    redirect "/contact"

  get "/contact":
    ### list all contacts
    let context = newContext()
    context["contacts"] = %db.all()
    resp "{{ >contacts }}".render(context)

  get "/contact/new":
    ## create new contact form
    resp "{{ >new_contact }}".render()

  get "/contact/@id":
    ## view individual contact
    let context = newContext()
    context["contact"] = %db.get(@"id".parseInt)
    resp "{{ >contact }}".render(context)

  get "/contact/@id/update":
    ## view individual contact
    let context = newContext()
    let contact = db.get(@"id".parseInt)
    echo contact
    context["contact"] = %contact
    resp "{{ >update_contact }}".render(context)

  post "/contact/new":
    ## create new contact
    let contact = Contact(
      name: request.params["name"],
      email: request.params["email"]
    )
    if db.create(contact):
      redirect "/contact"
    else:
      resp "error: failed to create contact"

  post "/contact/@id/delete":
    ## delete contact by id
    discard db.delete(@"id".parseInt)
    redirect "/contact"

  post "/contact/@id/update":
    ## update contact
    let contact = Contact(
      id: @"id".parseInt,
      name: request.params["name"],
      email: request.params["email"],
    )
    if db.update(contact):
      redirect "/contact"
    else:
      resp "error: failed to update contact"
