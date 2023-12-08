resource "libvirt_volume" "base-image" {
  name = "base_${var.image_name}"
  pool = "default"
  source = "${var.image_folder}/${var.image_name}"
  format = "qcow2"
}