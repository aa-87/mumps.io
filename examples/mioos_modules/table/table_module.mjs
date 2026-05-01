// Optional browser-side registration shim for a custom user bundle.
// The built-in table component already registers itself as `table`.
window.MIOOSModules?.registerModule?.({
  id: 'user.table.example',
  key: 'user.table.example',
  appKey: 'user.table.example',
  title: 'Table Example',
  description: 'Example user module using the backend table component.',
  source: 'user',
  category: 'Examples',
  icon: '▤',
  componentKey: 'table',
  surface: 'mioos-surface-table',
  tableState: {
    id: 'user-table-example',
    title: 'Table Example',
    dataset: 'demo'
  }
});
