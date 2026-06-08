import 'package:flutter/material.dart';
import 'user_model.dart';

const navy  = Color(0xFF1A2C5B);

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});
  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  String _search = '';
  String _roleFilter   = 'All Roles';
  String _statusFilter = 'All Status';
  int _page = 0;
  static const _pageSize = 4;

  List<UserAccount> get _filtered => mockUsers.where((u) {
    final q = _search.toLowerCase();
    return (q.isEmpty || u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.id.toLowerCase().contains(q))
        && (_roleFilter   == 'All Roles'   || u.role   == _roleFilter)
        && (_statusFilter == 'All Status'  || u.status == _statusFilter);
  }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered   = _filtered;
    final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 999);
    final paged      = filtered.skip(_page * _pageSize).take(_pageSize).toList();

    return Column(children: [
      // ── Header ──────────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Account Management',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 4),
          Text('Manage system access, assign roles, and update user credentials.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 14),
          // Add button
          SizedBox(width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showForm(context),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Add New User',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Search
          TextField(
            onChanged: (v) => setState(() { _search = v; _page = 0; }),
            decoration: InputDecoration(
              hintText: 'Search by name, email, or student ID...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          // Filters
          Row(children: [
            Expanded(child: _dropdown(_roleFilter,
                ['All Roles', 'System Admin', 'Facilities Responder', 'Academic Responder', 'Student', 'Staff'],
                (v) => setState(() { _roleFilter = v!; _page = 0; }))),
            const SizedBox(width: 10),
            Expanded(child: _dropdown(_statusFilter,
                ['All Status', 'Active', 'Inactive', 'Suspended'],
                (v) => setState(() { _statusFilter = v!; _page = 0; }))),
          ]),
        ]),
      ),
      const SizedBox(height: 10),
      // ── User List ────────────────────────────────────────────────────────────
      Expanded(
        child: paged.isEmpty
            ? const Center(child: Text('No users found.', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: paged.length,
                itemBuilder: (_, i) => _userCard(paged[i], context),
              ),
      ),
      // ── Pagination ───────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Showing ${_page * _pageSize + 1}–${_page * _pageSize + paged.length} of ${filtered.length} users',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Row(children: [
            _pageBtn(Icons.chevron_left,  _page > 0,              () => setState(() => _page--)),
            const SizedBox(width: 6),
            _pageBtn(Icons.chevron_right, _page < totalPages - 1, () => setState(() => _page++)),
          ]),
        ]),
      ),
    ]);
  }

  // ── User Card ──────────────────────────────────────────────────────────────
  Widget _userCard(UserAccount u, BuildContext context) {
    final statusColor = u.status == 'Active' ? Colors.green : u.status == 'Suspended' ? red : Colors.grey;
    final rc = roleColor(u.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: rc.withOpacity(0.15),
              child: Text(u.name[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: rc))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${u.name}${u.id.isNotEmpty ? ' · ${u.id}' : ''}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: navy)),
            Text(u.email, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: rc.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(u.role, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: rc)),
            ),
          ])),
          // Action buttons
          Column(children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
              onPressed: () => _showForm(context, existing: u),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              onPressed: () => _showMenu(context, u),
            ),
          ]),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          Text('${u.status}  ·  Last login: ${u.lastLogin}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
      ]),
    );
  }
  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(value: value, isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
            items: items.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: onChanged),
        ),
      );

  Widget _pageBtn(IconData icon, bool enabled, VoidCallback onTap) =>
      GestureDetector(onTap: enabled ? onTap : null,
        child: Container(width: 30, height: 30,
          decoration: BoxDecoration(
              color: enabled ? navy : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: enabled ? Colors.white : Colors.grey)));

  void _showForm(BuildContext context, {UserAccount? existing}) {
    showDialog(context: context, builder: (_) => _UserFormDialog(
      existing: existing,
      onSave: (u) => setState(() {
        if (existing != null) {
          final i = mockUsers.indexOf(existing);
          if (i != -1) mockUsers[i] = u;
        } else {
          mockUsers.add(u);
        }
      }),
    ));
  }

  void _showMenu(BuildContext context, UserAccount u) {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.block, color: Colors.orange),
            title: const Text('Suspend User'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                final i = mockUsers.indexOf(u);
                if (i != -1) mockUsers[i] = UserAccount(
                    name: u.name, email: u.email, role: u.role,
                    status: 'Suspended', lastLogin: u.lastLogin, id: u.id);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: red),
            title: const Text('Delete User', style: TextStyle(color: red)),
            onTap: () { Navigator.pop(context); setState(() => mockUsers.remove(u)); },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }
}

// ── User Form Dialog ──────────────────────────────────────────────────────────
class _UserFormDialog extends StatefulWidget {
  final UserAccount? existing;
  final Function(UserAccount) onSave;
  const _UserFormDialog({required this.onSave, this.existing});
  @override State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _name, _email, _id;
  String _role = 'Student', _status = 'Active';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name  = TextEditingController(text: e?.name  ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _id    = TextEditingController(text: e?.id    ?? '');
    if (e != null) { _role = e.role; _status = e.status; }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'Add New User' : 'Edit User',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: navy)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      _field(_name,  'Full Name',            Icons.person_outline),
      const SizedBox(height: 10),
      _field(_email, 'Email',                Icons.email_outlined),
      const SizedBox(height: 10),
      _field(_id,    'Student ID (optional)', Icons.badge_outlined),
      const SizedBox(height: 10),
      _formDropdown('Role', _role,
          ['System Admin', 'Facilities Responder', 'Academic Responder', 'Student', 'Staff'],
          (v) => setState(() => _role = v!)),
      const SizedBox(height: 10),
      _formDropdown('Status', _status, ['Active', 'Inactive', 'Suspended'],
          (v) => setState(() => _status = v!)),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(
        onPressed: () {
          if (_name.text.isEmpty || _email.text.isEmpty) return;
          widget.onSave(UserAccount(
              name: _name.text, email: _email.text,
              role: _role, status: _status, lastLogin: 'Just now', id: _id.text));
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Save'),
      ),
    ],
  );

  Widget _field(TextEditingController c, String hint, IconData icon) => TextField(
    controller: c,
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(fontSize: 12),
      prefixIcon: Icon(icon, size: 18, color: Colors.grey),
      filled: true, fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
  );

  Widget _formDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(value: value, isExpanded: true,
            items: items.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged),
        ),
      );
}