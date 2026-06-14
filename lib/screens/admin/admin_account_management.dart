import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/admin/admin_dashboard_screen.dart';

class _User {
  String name, email, role, status, lastLogin, id;
  String departemenId, nik, nip, noTelp, nim;

  _User({
    required this.name, required this.email,
    required this.role, required this.status, required this.lastLogin,
    this.id = '',
    this.departemenId = '', this.nik = '', this.nip = '',
    this.noTelp = '',      this.nim = '',
  });
}

final List<_User> _users = [
  _User(name: 'mas Jonny', email: 'Jonny@unej.mail.ac.id',
      role: 'Admin', status: 'Active', lastLogin: '2h ago',
      departemenId: 'DEPT-001', nik: '3509010101900001', nip: '197001012000011001', noTelp: '081234567890'),
  _User(name: 'Adoft Kittler', email: 'Kittler@unej.mail.ac.id',
      role: 'Penindak', status: 'Active', lastLogin: '1d ago',
      departemenId: 'DEPT-002', nik: '3509020202880002', nip: '198802022010011002', noTelp: '082233445566'),
  _User(name: 'Reza Auditore', email: '242410103000@unej.mail.ac.id',
      role: 'Mahasiswa', status: 'Active', lastLogin: '1h ago',
      id: 'ID: 2024011', nim: '242410103000'),
  _User(name: 'ladesh', email: 'ladesh@unej.mail.ac.id',
      role: 'Penindak', status: 'Active', lastLogin: '6h ago',
      departemenId: 'DEPT-003', nik: '3509030303900003', nip: '199003032015011003', noTelp: '085344556677'),
];

Color _roleColor(String role) {
  switch (role) {
    case 'Admin':         return kNavy;
    case 'Penindak': return const Color(0xFF00838F);
    case 'Mahasiswa':              return const Color(0xFF757575);
    default:                     return const Color(0xFF1565C0);
  }
}

class AdminAccountManagement extends StatefulWidget {
  const AdminAccountManagement({super.key});
  @override
  State<AdminAccountManagement> createState() => _AdminAccountManagementState();
}

class _AdminAccountManagementState extends State<AdminAccountManagement> {
  String _search      = '';
  String _roleFilter  = 'All Roles';
  String _statusFilter = 'Status: Active';
  int    _page        = 0;
  static const _pageSize = 4;
  static const _roleOptions   = ['All Roles', 'Admin','Mahasiswa', 'Penindak'];
  static const _statusOptions = ['Status: Active', 'Status: Inactive', 'Status: Suspended', 'All Status'];

  List<_User> get _filtered => _users.where((u) {
    final q = _search.toLowerCase();
    final matchQ = q.isEmpty
        || u.name.toLowerCase().contains(q)
        || u.email.toLowerCase().contains(q)
        || u.id.toLowerCase().contains(q);
    final matchR = _roleFilter == 'All Roles' || u.role == _roleFilter;
    final matchS = _statusFilter == 'All Status'
        || u.status == _statusFilter.replaceFirst('Status: ', '');
    return matchQ && matchR && matchS;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered   = _filtered;
    final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 999);
    final paged      = filtered.skip(_page * _pageSize).take(_pageSize).toList();

    return Column(children: [
      Expanded(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Monitoring Akun',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kNavy)),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola dan pantau semua akun pengguna di platform Suara MAWA. Tambahkan penindak baru, edit informasi pengguna, atau suspend akun yang melanggar aturan.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showForm(context),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('Add New User',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    onChanged: (v) => setState(() { _search = v; _page = 0; }),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or student ID...',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kNavy)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Filter row
                  Row(children: [
                    Expanded(child: _filterDropdown(_roleFilter, _roleOptions,
                        (v) => setState(() { _roleFilter = v!; _page = 0; }))),
                    const SizedBox(width: 10),
                    Expanded(child: _filterDropdown(_statusFilter, _statusOptions,
                        (v) => setState(() { _statusFilter = v!; _page = 0; }))),
                  ]),
                  const SizedBox(height: 6),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: paged.isEmpty
                  ? SliverToBoxAdapter(child: _emptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _UserCard(
                          user: paged[i],
                          onTap: () => _showDetail(context, paged[i]),
                          onEdit: () => _showForm(context, existing: paged[i]),
                          onMenu: () => _showMenu(context, paged[i]),
                        ),
                        childCount: paged.length,
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        ),
      ),

      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            'Showing ${_page * _pageSize + 1} to ${(_page * _pageSize + paged.length)} of ${filtered.length} users',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Row(children: [
            _pageBtn(Icons.chevron_left,  _page > 0,              () => setState(() => _page--)),
            const SizedBox(width: 6),
            _pageBtn(Icons.chevron_right, _page < totalPages - 1, () => setState(() => _page++)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _filterDropdown(String value, List<String> items, ValueChanged<String?> onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
            items: items.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _pageBtn(IconData icon, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: enabled ? kNavy : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: enabled ? Colors.white : Colors.grey),
        ),
      );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [
      Icon(Icons.search_off_outlined, size: 48, color: Colors.grey.shade300),
      const SizedBox(height: 10),
      Text('Tidak ada pengguna ditemukan',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
    ]),
  );

  void _showForm(BuildContext context, {_User? existing}) {
    showDialog(
      context: context,
      builder: (_) => _UserFormDialog(
        existing: existing,
        onSave: (u) => setState(() {
          if (existing != null) {
            final i = _users.indexOf(existing);
            if (i != -1) _users[i] = u;
          } else {
            _users.insert(0, u);
          }
        }),
      ),
    );
  }

  void _showMenu(BuildContext context, _User u) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: kNavy),
            title: const Text('Edit Pengguna', style: TextStyle(fontSize: 14)),
            onTap: () { Navigator.pop(context); _showForm(context, existing: u); },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.orange),
            title: const Text('Suspend Pengguna', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                final i = _users.indexOf(u);
                if (i != -1) _users[i].status = 'Suspended';
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: kRed),
            title: const Text('Hapus Pengguna', style: TextStyle(fontSize: 14, color: kRed)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _users.remove(u));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // Navigasi ke halaman detail
  void _showDetail(BuildContext context, _User u) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => _UserDetailPage(user: u)));
  }
}

class _UserCard extends StatelessWidget {
  final _User user;
  final VoidCallback onTap, onEdit, onMenu;
  const _UserCard({required this.user, required this.onEdit, required this.onMenu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rc = _roleColor(user.role);
    final isActive    = user.status == 'Active';
    final isSuspended = user.status == 'Suspended';
    final statusColor = isActive ? const Color(0xFF2E7D32)
        : isSuspended ? kRed
        : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 6, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: rc.withOpacity(0.12),
                child: Text(user.name[0].toUpperCase(),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: rc)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  user.id.isNotEmpty ? '${user.name} · ${user.id}' : user.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kNavy),
                ),
                const SizedBox(height: 2),
                Text(user.email, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: rc.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_roleIcon(user.role), size: 11, color: rc),
                    const SizedBox(width: 4),
                    Text(user.role,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: rc)),
                  ]),
                ),
              ])),
              Column(children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: onMenu,
                ),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(children: [
              Container(width: 7, height: 7,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(user.status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              Text('  ·  Last login: ${user.lastLogin}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
            ]),
          ),
        ]),
      ),
    );
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'Admin':         return Icons.shield_outlined;
      case 'Penindak':      return Icons.gavel_outlined;
      case 'Mahasiswa':     return Icons.school_outlined;
      default:              return Icons.person_outline;
    }
  }
}

class _UserFormDialog extends StatefulWidget {
  final _User? existing;
  final Function(_User) onSave;
  const _UserFormDialog({required this.onSave, this.existing});
  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _name, _email, _id;
  late final TextEditingController _departemenId, _nik, _nip, _noTelp;
  String _status = 'Active';

  static const _statuses = ['Active', 'Inactive', 'Suspended'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name   = TextEditingController(text: e?.name   ?? '');
    _email  = TextEditingController(text: e?.email  ?? '');
    _id     = TextEditingController(text: e?.id     ?? '');
    
    _departemenId = TextEditingController(text: e?.departemenId ?? '');
    _nik    = TextEditingController(text: e?.nik ?? '');
    _nip    = TextEditingController(text: e?.nip ?? '');
    _noTelp = TextEditingController(text: e?.noTelp ?? '');
    
    if (e != null) { _status = e.status; }
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _id.dispose();
    _departemenId.dispose(); _nik.dispose(); _nip.dispose(); _noTelp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final currentRole = isEdit ? widget.existing!.role : 'Penindak';

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(width: 32, height: 32,
            decoration: BoxDecoration(color: kNavy.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person_add_outlined, size: 18, color: kNavy)),
        const SizedBox(width: 10),
        Text(isEdit ? 'Edit Pengguna' : 'Tambah Penindak',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kNavy)),
      ]),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _field(_name,  'Nama Lengkap', Icons.person_outline),
          const SizedBox(height: 10),
          _field(_email, 'Email', Icons.email_outlined),
          const SizedBox(height: 10),
          
          if (currentRole == 'Penindak' || currentRole == 'Admin') ...[
            _field(_departemenId, 'Departemen ID', Icons.domain),
            const SizedBox(height: 10),
            _field(_nik, 'NIK', Icons.credit_card),
            const SizedBox(height: 10),
            _field(_nip, 'NIP', Icons.badge_outlined),
            const SizedBox(height: 10),
            _field(_noTelp, 'Nomor Telepon', Icons.phone_outlined),
            const SizedBox(height: 10),
          ] else if (currentRole == 'Mahasiswa') ...[
             _field(_id, 'NIM / Student ID', Icons.badge_outlined),
             const SizedBox(height: 10),
          ],

          _formDrop('Status', _status, _statuses, (v) => setState(() => _status = v!)),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) return;
            widget.onSave(_User(
              name: _name.text.trim(), 
              email: _email.text.trim(),
              role: currentRole, 
              status: _status, 
              lastLogin: isEdit ? widget.existing!.lastLogin : 'Baru saja', 
              id: _id.text.trim(),
              departemenId: _departemenId.text.trim(),
              nik: _nik.text.trim(),
              nip: _nip.text.trim(),
              noTelp: _noTelp.text.trim(),
              nim: currentRole == 'Mahasiswa' ? _id.text.trim() : (isEdit ? widget.existing!.nim : ''),
            ));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kNavy, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon) {
    const bgColor = Color(0xFFF5F5F5); 
    return TextField(
      controller: c,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey),
        filled: true, fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _formDrop(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    const bgColor = Color(0xFFF5F5F5); 
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          items: items.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _UserDetailPage extends StatelessWidget {
  final _User user;

  const _UserDetailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detail Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: kNavy,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _roleColor(user.role).withOpacity(0.12),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _roleColor(user.role)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kNavy)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _roleColor(user.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(color: _roleColor(user.role), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
              ),
              
              // Detail Spesifik Berdasarkan Role
              if (user.role == 'Mahasiswa') ...[
                _buildInfoRow(Icons.email_outlined, 'Email', user.email),
                _buildInfoRow(Icons.badge_outlined, 'NIM', user.nim.isNotEmpty ? user.nim : user.id),
              ] else ...[
                _buildInfoRow(Icons.domain, 'Departemen ID', user.departemenId),
                _buildInfoRow(Icons.email_outlined, 'Email', user.email),
                _buildInfoRow(Icons.credit_card, 'NIK', user.nik),
                _buildInfoRow(Icons.badge_outlined, 'NIP', user.nip),
                _buildInfoRow(Icons.phone_outlined, 'Nomor Telepon', user.noTelp),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}