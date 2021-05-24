extends Node2D

var x509_cert_filename = "X509_Certificate.crt"
var x509_key_filename = "X509_Key.key"

onready var X509_cert_path = "user://Certificate/" + x509_cert_filename
onready var x509_key_path = "user://Certificate/" + x509_key_filename

var CN = "MultiplayerNarkian"
var O = "NineGameStudio"
var C = "BR"
var not_before = "20210520000000"
var not_after = "20220519235900"

func _ready():
	var directory = Directory.new()
	if directory.dir_exists("user://Certificate/"):
		pass
	else:
		directory.make_dir("user://Certificate/")
	create_x509_cert()
	print("Certificate created")

func create_x509_cert():
	var CNOC = "CN=" + CN +",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(x509_key_path)
	
