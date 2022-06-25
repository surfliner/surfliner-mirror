The Access Control Model in `comet`
===================================

~comet follows [Hyrax][hyrax]’s model for access controls, which is designed to
be serializable in the [Web ACL][webacl] model.

> ※ Although it follows the broad model of Web ACL, the exact serialization is
> as yet to be determined. The important parts of this model are described in
> the “Data Model” section below.

## Overview

ACLs are administrative metadata with a global scope governing authorization and
access to repository resources. The ACL data is intended to be limited in terms
of what kinds of authorization it governs, but where it applies it is iron clad
and universal.

This means that if you want to answer questions like “is this **Agent** allowed
to `:read`/`:edit` this **Object**/**File**/**Collection**”, the ACL data forms
a hard requirement which all Surfliner applications MUST respect; if there isn’t
a grant for the relevant access in the ACL data, they CANNOT provide it,
regardless of application context.

> ※ Actually, there is (currently) an exception to the above, in that ~comet
> administrators always have the ability to perform all actions. This is to
> mitigate loss of control (having objects in ~comet which nobody can access),
> although the exact mechanisms of this may be subject to revision.

Conceptually, ACL metadata _describes_ but does not _belong to_ resources,
instead existing in the form of ACL documents (represented by **AccessControl**
resources), each of which collects all the permissions granted for a specific
resource. This separation means that changing the ACLs for a resource need not
impact its stored metadata (and vice versa); for more information and examples
regarding **AccessControl** resources, see the remarks on **AccessControl** and
**AccessControlList** below. ACL documents are stored at the “top level” of the
Valkyrie store; you need only (and must) have an appropriate resource identifier
to access the corresponding ACL.

The scope of ACL requirements is limited to the **Access Modes** documented
here. These access modes are generally limited to the metadata of the resource
or its binary representation—the things stored by Valkyrie and which might be
accessible via an API—and not application‐specific particulars of how a
particular resource is handled. Applications are free to define their own
authorization mechanisms for actions taken on resources, but they SHOULD take
care to respect ACL access when doing so.

> ※ As an example, a given application might choose to allow or deny download
> access using any business logic it desires. In doing so, however, it is
> required to respect `:read` access as represented in the ACLs; if the user
> isn’t granted `:read`, the application is bound to deny download. By contrast,
> an application that wants to authorize attaching a UI widget to a resource may
> do so even if the user lacks `:read` access, since the action’s impact is
> limited to the application.

> ※ A complex example of application layer authorization is ~comet’s role‐based
> workflow engine. Since the workflow data is isolated to ~comet, workflow state
> changes can be authorized without reference to ACLs. However, when a state
> change triggers an action which modifies **Object** or **Collection**
> metadata, that action needs to authorize the user for `:edit` before
> persisting those changes.

## Data Model

ACL metadata is maintained in the ~comet metadata store, using a
[Valkyrie][valkyrie] metadata adapter. **AccessControl** resources are stored as
first‐class entities, separate from the resources they govern. **Permission**
resources are embedded within the **AccessControl** associated with the resource
they provide `:access_to`.

These types can be described as follows:

### **AccessControl**

**AccessControl** resources (`Hyrax::AccessControl`) represent an ACL document,
corresponding to an [ACL Resource Representation][webacl-acl-resource]. By
convention, each resource in ~comet SHOULD have at most one **AccessControl**.
This document is treated as the canonical document governing access to that
resource across Surfliner systems (i.e. by default, it is the
[Effective ACL Resource][webacl-effective] throughout Surfliner).

The **AccessControl** consists of a reference to the governed resource
(`:access_to`) and a set of permission resources defining the access conditions
(`:permissions`). The `:access_to` reference supports discovery of the
**AccessControl** record in relation to the resource governed; its value MUST
identify the appropriate resource.

<dl>
  <dt><code>:access_to</code></dt>
  <dd>

An identifier reference to the resource this **AccessControl** document governs.

  </dd>
</dl>

<dl>
  <dt><code>:permissions</code></dt>
  <dd>

A set of `Hyrax::Permission` resources.

  </dd>
</dl>

To get the ACL document for a given resource, you can use the `.for` method:

```ruby
access_control = Hyrax::AccessControl.for(resource: my_resource)
# access_control.access_to == my_resource.id
```

This will create a new **AccessControl** resource for the provided resource if
one does not already exist. However, it is generally preferable to manage ACLs
using an **AccessControlList**, as described below.

### **Permission**

**Permission** resources (`Hyrax::Permission`) define an individual access grant
to a specified **Agent**. These correspond to
[Authorization Rules][webacl-authorization] in the Web ACL model.

<dl>
  <dt><code>:access_to</code></dt>
  <dd>

An identifier reference to the resource this **Permission** grants access to.

  </dd>
</dl>

<dl>
  <dt><code>:agent</code></dt>
  <dd>

A String representing the **Agent** this **Permission** grants the ability to
perform operations on the resource.

  </dd>
</dl>

<dl>
  <dt><code>:mode</code></dt>
  <dd>

A Symbol defining the **Access Mode** granted by the **Permission** to the
**Agent**.

  </dd>
</dl>

See below for more on the precise meaning of **Agents** and **Access Modes**.

## **Agents**

~comet acknowledges two kinds of **Agent**: **Groups** and **Users**.

A **Group** is identified by the string `group/` followed by its group name. A
few **Groups** have special significance:

- `group/public` represents the general public. Permissions granted to this
group apply to everyone.

- `group/❲platform❳` represents all the users on a given discovery platform; for
example, users from ~tidewater are represented by `group/tidewater`.

- `group/ip_allowed` represents all the users coming from an allow‐listed IP
address.

A **User** is identified by its user key (which must not begin with `group/`).

## **Access Modes**

~comet currently recognizes the following **Access Modes**:

### `:read`

`:read` grants access to read all aspects of the resource. For example, if the
resource is an **Object** or **Collection**, this mode allows the **Agent** to
view the metadata associated with that resource. If the resource is a **File**,
it additionally allows the **Agent** to view and download the file contents.

### `:edit`

`:edit` grants access to change all aspects of the resource. For an **Object**
or **Collection** this means altering the metadata; for a **File** it
additionally means editing its binary contents.

### `:discover`

`:discover` is used to enable access to discovery platforms / over the API. It
implies `:read`, but is more specific (in that making a resource publicly
readable does not necessarily make it discoverable in all platforms).

## Using **AccessControlLists** to manage access controls

**AccessControlLists** (`Hyrax::AccessControlList`;
[documentation on RubyDoc][rubydoc-hyrax-acl]) provide a simple interface for
managing the **Permissions** associated with a resource via its
**AccessControl**. You can create one by providing the resource in question to
its initializer:

```ruby
access_control_list = Hyrax::AccessControlList.new(resource: my_resource)
```

The `#resource` method returns the associated resource, and the `#permissions`
method returns a set of associated **Permissions**. It is possible to overwrite
the **Permissions** completely by setting `#permissions`, but typically other
mechanisms for modifying the **Permissions** are preferable.

The `#grant` method can be used to grant a **Permission**, and the `#revoke`
method can be used to revoke it. These methods return objects with a `#to` or
`#from` method, respectively, for specifying the **Agent**, and can be used as
follows:

<!--

> ☡ This may not work with groups right now; see
> <https://gitlab.com/surfliner/surfliner/-/blob/3038d2fd1ba14be5f2c2ed7d08e8a91ec810d750/comet/app/services/discovery_platform_publisher.rb#L110>.

-->

```ruby
access_control_list.grant(:read).to(my_agent)
# access_control_list.permissions now contains a Permission for my_agent to
# :read my_object.

access_control_list.revoke(:read).from(my_agent)
# access_control_list.permissions no longer contains a Permission for my_agent
# to :read my_object.
```

> ☡ Even if you have revoked a **Permission** from an **Agent**, it is still
> possible that that **Agent** can perform the corresponding action if the
> **Agent** belongs to a **Group** with those permissions. For example, it is
> not possible to practically revoke `:read` from a specific **Agent** if
> `:read` access is granted to `group/public`.

<!--

> ☡ The following does not currently work, but I feel like it should (i.e. this
> is a bug upstream). See remarks @
> <https://gitlab.com/surfliner/surfliner/-/blob/3038d2fd1ba14be5f2c2ed7d08e8a91ec810d750/comet/app/services/discovery_platform_publisher.rb#L91-97>
>
> I would also like it if upstream had a dedicated method for this which doesn’t
> rely on knowing how **Agent** strings are derived from various classes.

You can see if a permission already exists in the ACLs for a resource by trying
to change it, and testing whether this results in `#pending_changes?`:

```ruby
##
# Returns whether the provided +agent+ has +:read+ permissions for the provided
# +resource+.
def readable_by?(agent, resource:)
  test_acl = Hyrax::AccessControlList.new(resource: resource)
  test_acl.grant(:read).to(agent)
  !test_acl.pending_changes?
end
```

> ☡ Be sure not to persist this test!

-->

If you already know the type of the **Agent**, the easiest way to test for a
given **Permission** is to use `Hyrax::PermissionManager`, which provides the
`#read_users`, `#read_groups`, `#edit_users`, and `#edit_groups` methods.

```ruby
##
# Returns whether the public group has +:read+ permissions for the provided
# +resource+.
def readable_by_public?(resource:)
  permission_manager = Hyrax::PermissionManager.new(resource: resource)
  permission_manager.read_groups.include?("public")
end
```

In order to persist changes to an **AccessControlList**, you need to call the
`#save` method:

```ruby
access_control_list.save
```

This will persist any changes to the ACL to the Valkyrie store.

[hyrax]: https://github.com/samvera/hyrax "Hyrax on GitHub"
[rubydoc-hyrax-acl]: https://rubydoc.info/gems/hyrax/Hyrax/AccessControlList "Class: Hyrax::AccessControlList"
[valkyrie]: https://github.com/samvera/valkyrie "Valkyrie on GitHub"
[webacl]: https://solid.github.io/web-access-control-spec/ "SOLID Web Access Control"
[webacl-acl-resource]: https://solid.github.io/web-access-control-spec/#acl-resource-representation "SOLID Web Access Control: ACL Resource Representation"
[webacl-authorization]: https://solid.github.io/web-access-control-spec/#authorization-rule "SOLID Web Access Control: Authorization Rule"
[webacl-effective]: https://solid.github.io/web-access-control-spec/#effective-acl-resource "SOLID Web Access Control: Effective ACL Resource"
