The Access Control Model in `comet`
===================================

`comet` follows [Hyrax][hyrax]'s model for access controls, which is designed
to be serializable in the [Web ACL][webacl] model.

## Data Model

### `Hyrax::AccessControl`

**AccessControl** resources represent an ACL document, corresponding to an
[ACL Resource Representation][webacl-acl-resource]. By convention, each resource
in `comet` SHOULD have at most one **AccessControl**. This document is treated
as the canonical document governing access to that resource across Surfliner
systems (i.e. by default, it is the [Effective ACL Resource][webacl-effective]
throughout Surfliner).

The **AccessControl** consists of a reference to the governed resource
(`:access_to`) and a set of permission resources defining the access conditions
(`:permissions`). The `:access_to` reference supports discovery of the
**AccessControl** record in relation to the resource governed; its value MUST
identify the appropriate resource.

<dl>
  <dt><code>:access_to</code></dt>
  <dd>
    An identifier reference to the resource this **AccessControl** document
    governs.
  </dd>
</dl>

<dl>
  <dt><code>:permissions</code></dt>
  <dd>
    A set of `Hyrax::Permission` resources.
  </dd>
</dl>

### `Hyrax::Permission`

**Permission** resources define an individual access grant to a specified
**`Agent`**. These correspond to [Authorization Rules][webacl-authorization]
in the Web ACL model.

<dl>
  <dt><code>:access_to</code></dt>
  <dd>
    An identifier reference to the resource this **Permission** grants
    access to.
  </dd>
</dl>

<dl>
  <dt><code>:agent</code></dt>
  <dd>
    A String representing the **Agent** (an individual user, or a group) this
    **Permission** grants the ability to perform operations on the resource.
  </dd>
</dl>

<dl>
  <dt><code>:mode</code></dt>
  <dd>
    A Symbol defining the **Mode** (e.g. `:read`, `:edit`) of access granted by the
    **Permission** to the **Agent**.
  </dd>
</dl>

## Access Modes

### `:read`

`:read` grants access to read all aspects of the resource. For example, if the
resource is a `pcdm:Object`, this mode allows the **Agent** to view the metadata
associated with that resource. If the resource is a `pcdm:File`, it allows the
**Agent** to view and download the file contents.

### `:edit`

`:edit` grants access to change all aspects of the resource.

## Storage and Data Layout Considerations

ACL metadata is maintained in the `comet` metadata store, using a
[`valkyrie`][valkyrie] metadata adapter. The `Hyrax::AccessControl` resources
are stored as first-class entities, separate from the resources they govern.
`Hyrax::Permission` resources are embedded within a given `Hyrax::AccessControl`.

This data layout means that a given **AccessControl** can be edited directly,
without accessing other resource metadata in any way. But it also has the
implication that **Permissions** will only be discovered and applied insofar as
they are a part of the **AccessControl** document.

Developers should look to [`Hyrax::AccessControlList`][rubydoc-hyrax-acl] for
a set of tools for managing an **AccessControl** and its associated
**Permissions** in the context of a resource.


[hyrax]: https://github.com/samvera/hyrax "Hyrax on GitHub"
[rubydoc-hyrax-acl]: https://rubydoc.info/gems/hyrax/Hyrax/AccessControlList "Class: Hyrax::AccessControlList"
[valkyrie]: https://github.com/samvera/valkyrie "Valkyrie on GitHub"
[webacl]: https://solid.github.io/web-access-control-spec/ "SOLID Web Access Control"
[webacl-acl-resource]: https://solid.github.io/web-access-control-spec/#acl-resource-representation "SOLID Web Access Control: ACL Resource Representation"
[webacl-authorization]: https://solid.github.io/web-access-control-spec/#authorization-rule
"SOLID Web Access Control: Authorization Rule"
[webacl-effective]: https://solid.github.io/web-access-control-spec/#effective-acl-resource "SOLID Web Access Control: Effective ACL Resource"
