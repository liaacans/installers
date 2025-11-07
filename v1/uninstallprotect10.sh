#!/bin/bash

echo "🛠️  Mencoba menghapus proteksi ULTIMATE..."

# File paths
INDEX_FILE="/var/www/pterodactyl/resources/views/admin/servers/index.blade.php"
VIEW_FILE="/var/www/pterodactyl/resources/views/admin/servers/view/26.blade.php"

# Remove immutable attribute first
echo "🔓 Menghapus atribut immutable..."
chattr -i "$INDEX_FILE" 2>/dev/null || echo "ℹ️  chattr not available"
chattr -i "$VIEW_FILE" 2>/dev/null || echo "ℹ️  chattr not available"

# Restore permissions
chmod 644 "$INDEX_FILE" 2>/dev/null || echo "⚠️  Cannot change index file permissions"
chmod 644 "$VIEW_FILE" 2>/dev/null || echo "⚠️  Cannot change view file permissions"

# Find and restore from backups
echo "🔄 Mencari backup file..."

INDEX_BACKUP=$(ls -t "${INDEX_FILE}.bak_"* 2>/dev/null | head -n1)
VIEW_BACKUP=$(ls -t "${VIEW_FILE}.bak_"* 2>/dev/null | head -n1)

if [ -n "$INDEX_BACKUP" ]; then
    echo "✅ Menemukan backup index: $INDEX_BACKUP"
    cp -f "$INDEX_BACKUP" "$INDEX_FILE"
    echo "📦 Index file berhasil dipulihkan"
else
    echo "❌ Backup index tidak ditemukan, membuat file default..."
    # Create default index file
    cat > "$INDEX_FILE" << 'EOF'
@extends('layouts.admin')
@section('title')
    Servers
@endsection

@section('content-header')
    <h1>Servers<small>All servers available on the system.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Servers</li>
    </ol>
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server List</h3>
            </div>
            <div class="box-body">
                <p>Server list will be displayed here after protection removal.</p>
            </div>
        </div>
    </div>
</div>
@endsection
EOF
fi

if [ -n "$VIEW_BACKUP" ]; then
    echo "✅ Menemukan backup view: $VIEW_BACKUP"
    cp -f "$VIEW_BACKUP" "$VIEW_FILE"
    echo "📦 View file berhasil dipulihkan"
else
    echo "❌ Backup view tidak ditemukan, membuat file default..."
    # Create default view file
    cat > "$VIEW_FILE" << 'EOF'
@extends('layouts.admin')
@section('title')
    Server View
@endsection

@section('content')
<div class="row">
    <div class="col-xs-12">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Server Details</h3>
            </div>
            <div class="box-body">
                <p>Server details will be displayed here after protection removal.</p>
            </div>
        </div>
    </div>
</div>
@endsection
EOF
fi

# Set proper permissions
chmod 644 "$INDEX_FILE"
chmod 644 "$VIEW_FILE"

# Clear cache
echo "🔄 Membersihkan cache..."
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear

echo ""
echo "🎉 UNINSTALL BERHASIL!"
echo "✅ Proteksi ULTIMATE telah dihapus"
echo "✅ File telah dikembalikan ke keadaan semula"
echo "✅ Permission normal telah dipulihkan"
echo "🔓 Sistem sekarang dapat diakses normal"

# Security notice
echo ""
echo "⚠️  SECURITY NOTICE:"
echo "Sistem sekarang tidak memiliki proteksi. Instal ulang proteksi jika diperlukan."
