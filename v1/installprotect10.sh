#!/bin/bash

REMOTE_PATH="/var/www/pterodactyl/resources/scripts/admin/nodes/view/1/index.blade.php"
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
BACKUP_PATH="${REMOTE_PATH}.bak_${TIMESTAMP}"

echo "🚀 Memasang proteksi Anti Akses Node View..."

if [ -f "$REMOTE_PATH" ]; then
  mv "$REMOTE_PATH" "$BACKUP_PATH"
  echo "📦 Backup file lama dibuat di $BACKUP_PATH"
fi

mkdir -p "$(dirname "$REMOTE_PATH")"
chmod 755 "$(dirname "$REMOTE_PATH")"

cat > "$REMOTE_PATH" << 'EOF'
@extends('layouts.admin')
@section('title')
    Nodes &rarr; View &rarr; {{ $node->name }}
@endsection

@section('content-header')
    <h1>{{ $node->name }}<small>Detailed overview of this node.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.nodes') }}">Nodes</a></li>
        <li class="active">{{ $node->name }}</li>
    </ol>
@endsection

@section('content')
<style>
.protection-banner {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 20px;
    border-left: 4px solid #ff4757;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}
.protection-banner h4 {
    margin: 0 0 5px 0;
    font-weight: 600;
}
.protection-banner p {
    margin: 0;
    opacity: 0.9;
}
.access-denied {
    text-align: center;
    padding: 60px 20px;
    background: #f8f9fa;
    border-radius: 10px;
    margin: 20px 0;
    border: 2px dashed #dee2e6;
}
.access-denied i {
    font-size: 48px;
    color: #ff4757;
    margin-bottom: 20px;
}
.access-denied h3 {
    color: #495057;
    margin-bottom: 15px;
}
.access-denied p {
    color: #6c757d;
    max-width: 500px;
    margin: 0 auto 20px;
}
</style>

<div class="row">
    <div class="col-xs-12">
        <div class="protection-banner">
            <h4>🚫 Protected Access - Node View</h4>
            <p>This node view is protected by security measures. Only authorized administrators can access detailed node information.</p>
        </div>
    </div>
</div>

@php
    $user = Auth::user();
    $isAuthorized = $user && $user->id === 1;
@endphp

@if(!$isAuthorized)
<div class="row">
    <div class="col-xs-12">
        <div class="access-denied">
            <i class="fa fa-shield"></i>
            <h3>Access Denied</h3>
            <p>You do not have permission to view this node's detailed information. This area is restricted to authorized administrators only.</p>
            <div class="alert alert-warning" style="max-width: 400px; margin: 0 auto;">
                <i class="fa fa-exclamation-triangle"></i>
                <strong>Protected by:</strong> @ginaabaikhati Security System
            </div>
        </div>
    </div>
</div>
@else
<!-- Original Node View Content for Authorized Admin -->
<div class="row">
    <div class="col-xs-12">
        <div class="nav-tabs-custom nav-tabs-floating">
            <ul class="nav nav-tabs">
                <li class="active"><a href="#overview" data-toggle="tab">Overview</a></li>
                <li><a href="#settings" data-toggle="tab">Settings</a></li>
                <li><a href="#configuration" data-toggle="tab">Configuration</a></li>
                <li><a href="#allocation" data-toggle="tab">Allocation</a></li>
                <li><a href="#servers" data-toggle="tab">Servers</a></li>
            </ul>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-sm-6">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Information</h3>
            </div>
            <div class="box-body">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="row">
                            <div class="col-sm-6 text-center">
                                <div class="info-box bg-blue">
                                    <span class="info-box-icon"><i class="fa fa-server"></i></span>
                                    <div class="info-box-content">
                                        <span class="info-box-text">Total Servers</span>
                                        <span class="info-box-number">{{ $node->servers_count }}</span>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6 text-center">
                                <div class="info-box bg-green">
                                    <span class="info-box-icon"><i class="fa fa-hdd-o"></i></span>
                                    <div class="info-box-content">
                                        <span class="info-box-text">Disk Usage</span>
                                        <span class="info-box-number">{{ $node->getDiskUsage() }}%</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-sm-6">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">System Information</h3>
            </div>
            <div class="box-body">
                <dl>
                    <dt>Node Name</dt>
                    <dd>{{ $node->name }}</dd>
                    <dt>Location</dt>
                    <dd>{{ $node->location->short }}</dd>
                    <dt>Connection</dt>
                    <dd><code>{{ $node->scheme }}://{{ $node->fqdn }}:{{ $node->daemonListen }}}</code></dd>
                    <dt>Memory</dt>
                    <dd>{{ $node->memory }} MB</dd>
                    <dt>Disk</dt>
                    <dd>{{ $node->disk }} MB</dd>
                </dl>
            </div>
        </div>
    </div>
</div>
@endif
@endsection
EOF

chmod 644 "$REMOTE_PATH"

echo "✅ Proteksi Anti Akses Node View berhasil dipasang!"
echo "📂 Lokasi file: $REMOTE_PATH"
echo "🗂️ Backup file lama: $BACKUP_PATH (jika sebelumnya ada)"
echo "🔒 Hanya Admin (ID 1) yang bisa akses Node View detail."
