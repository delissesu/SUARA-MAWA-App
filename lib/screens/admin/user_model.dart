import 'package:flutter/material.dart';

const navy  = Color(0xFF1A2C5B);
const teal  = Color(0xFF4DD0C4);
const red   = Color(0xFFE53935);

class UserAccount {
  final String name, email, role, status, lastLogin, id;
  UserAccount({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastLogin,
    this.id = '',
  });
}

// Shared in-memory "database" — import this list in both pages
final List<UserAccount> mockUsers = [
  UserAccount(name: 'Sarah Jenkins',   email: 'sarah.j@institution.edu',  role: 'System Admin',         status: 'Active',    lastLogin: '2h ago'),
  UserAccount(name: 'Michael Chen',    email: 'm.chen@facilities.edu',     role: 'Facilities Responder', status: 'Active',    lastLogin: '1d ago'),
  UserAccount(name: 'Alex Rodriguez',  email: 'alex.r@student.edu',        role: 'Student',              status: 'Suspended', lastLogin: '2w ago', id: 'ID: 2023901'),
  UserAccount(name: 'Dr. Emily Vance', email: 'e.vance@academic.edu',      role: 'Academic Responder',   status: 'Inactive',  lastLogin: '1mo ago'),
  UserAccount(name: 'James Okonkwo',   email: 'j.okonkwo@staff.edu',       role: 'Staff',                status: 'Active',    lastLogin: '3h ago'),
  UserAccount(name: 'Priya Sharma',    email: 'p.sharma@institution.edu',  role: 'System Admin',         status: 'Active',    lastLogin: '5d ago'),
];

Color roleColor(String role) {
  switch (role) {
    case 'System Admin':         return navy;
    case 'Facilities Responder': return const Color(0xFF00838F);
    case 'Academic Responder':   return const Color(0xFF6A1B9A);
    case 'Student':              return const Color(0xFF757575);
    default:                     return const Color(0xFF1565C0);
  }
}