# -*- coding: utf-8 -*-
from south.utils import datetime_utils as datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'Device'
        db.create_table(u'notifications_device', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('device_token', self.gf('django.db.models.fields.CharField')(unique=True, max_length=64)),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['auth.User'])),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=50)),
        ))
        db.send_create_signal(u'notifications', ['Device'])

        # Adding model 'Feed'
        db.create_table(u'notifications_feed', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('user', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['auth.User'])),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=50)),
        ))
        db.send_create_signal(u'notifications', ['Feed'])

        # Adding M2M table for field devices on 'Feed'
        m2m_table_name = db.shorten_name(u'notifications_feed_devices')
        db.create_table(m2m_table_name, (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('feed', models.ForeignKey(orm[u'notifications.feed'], null=False)),
            ('device', models.ForeignKey(orm[u'notifications.device'], null=False))
        ))
        db.create_unique(m2m_table_name, ['feed_id', 'device_id'])

        # Adding model 'UserToken'
        db.create_table(u'notifications_usertoken', (
            ('key', self.gf('django.db.models.fields.CharField')(max_length=40, primary_key=True)),
            ('user', self.gf('django.db.models.fields.related.OneToOneField')(related_name='user_key', unique=True, to=orm['auth.User'])),
        ))
        db.send_create_signal(u'notifications', ['UserToken'])

        # Adding model 'Notification'
        db.create_table(u'notifications_notification', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('sent_date', self.gf('django.db.models.fields.DateTimeField')(auto_now_add=True, blank=True)),
            ('viewed', self.gf('django.db.models.fields.BooleanField')(default=False)),
            ('feed', self.gf('django.db.models.fields.related.ForeignKey')(to=orm['notifications.Feed'])),
            ('title', self.gf('django.db.models.fields.CharField')(max_length=256)),
            ('message', self.gf('django.db.models.fields.TextField')()),
        ))
        db.send_create_signal(u'notifications', ['Notification'])


    def backwards(self, orm):
        # Deleting model 'Device'
        db.delete_table(u'notifications_device')

        # Deleting model 'Feed'
        db.delete_table(u'notifications_feed')

        # Removing M2M table for field devices on 'Feed'
        db.delete_table(db.shorten_name(u'notifications_feed_devices'))

        # Deleting model 'UserToken'
        db.delete_table(u'notifications_usertoken')

        # Deleting model 'Notification'
        db.delete_table(u'notifications_notification')


    models = {
        u'auth.group': {
            'Meta': {'object_name': 'Group'},
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        u'auth.permission': {
            'Meta': {'ordering': "(u'content_type__app_label', u'content_type__model', u'codename')", 'unique_together': "((u'content_type', u'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['contenttypes.ContentType']"}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        u'auth.user': {
            'Meta': {'object_name': 'User'},
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'first_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'symmetrical': 'False', 'related_name': "u'user_set'", 'blank': 'True', 'to': u"orm['auth.Group']"}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'last_name': ('django.db.models.fields.CharField', [], {'max_length': '30', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'symmetrical': 'False', 'related_name': "u'user_set'", 'blank': 'True', 'to': u"orm['auth.Permission']"}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '30'})
        },
        u'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        u'notifications.device': {
            'Meta': {'object_name': 'Device'},
            'device_token': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '64'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['auth.User']"})
        },
        u'notifications.feed': {
            'Meta': {'object_name': 'Feed'},
            'devices': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['notifications.Device']", 'symmetrical': 'False'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'}),
            'user': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['auth.User']"})
        },
        u'notifications.notification': {
            'Meta': {'object_name': 'Notification'},
            'feed': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['notifications.Feed']"}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'message': ('django.db.models.fields.TextField', [], {}),
            'sent_date': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '256'}),
            'viewed': ('django.db.models.fields.BooleanField', [], {'default': 'False'})
        },
        u'notifications.usertoken': {
            'Meta': {'object_name': 'UserToken'},
            'key': ('django.db.models.fields.CharField', [], {'max_length': '40', 'primary_key': 'True'}),
            'user': ('django.db.models.fields.related.OneToOneField', [], {'related_name': "'user_key'", 'unique': 'True', 'to': u"orm['auth.User']"})
        }
    }

    complete_apps = ['notifications']