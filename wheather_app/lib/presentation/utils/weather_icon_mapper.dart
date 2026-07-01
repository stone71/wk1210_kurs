import 'package:flutter/material.dart';

IconData weatherIconFromCode(int code) {
  switch (code) {
    case 0:
      return Icons.wb_sunny;
    case 1:
      return Icons.wb_sunny;
    case 2:
      return Icons.cloud_queue;
    case 3:
      return Icons.cloud;
    case 45:
    case 48:
      return Icons.foggy;
    case 51:
    case 53:
    case 55:
      return Icons.grain;
    case 56:
    case 57:
      return Icons.ac_unit;
    case 61:
    case 63:
    case 65:
      return Icons.water_drop;
    case 66:
    case 67:
      return Icons.ac_unit;
    case 71:
    case 73:
    case 75:
    case 77:
      return Icons.ac_unit;
    case 80:
    case 81:
    case 82:
      return Icons.shower;
    case 85:
    case 86:
      return Icons.ac_unit;
    case 95:
    case 96:
    case 99:
      return Icons.flash_on;
    default:
      return Icons.help_outline;
  }
}

Color weatherIconColor(int code) {
  switch (code) {
    case 0:
    case 1:
      return Colors.orange;
    case 2:
    case 3:
      return Colors.grey;
    case 45:
    case 48:
      return Colors.blueGrey;
    case 51:
    case 53:
    case 55:
    case 61:
    case 63:
    case 65:
    case 80:
    case 81:
    case 82:
      return Colors.blue;
    case 56:
    case 57:
    case 66:
    case 67:
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return Colors.lightBlue;
    case 95:
    case 96:
    case 99:
      return Colors.deepPurple;
    default:
      return Colors.grey;
  }
}
