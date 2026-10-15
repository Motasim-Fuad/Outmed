import 'package:flutter/material.dart';
import 'package:outmed/features/supplier/data/models/category_option.dart';

extension CategoryIcon on CategoryOption {
  IconData get icon {
    final key = '$name $slug'.toLowerCase();
    if (key.contains('ppe') || key.contains('safety')) {
      return Icons.health_and_safety_outlined;
    }
    if (key.contains('surg')) return Icons.cut_rounded;
    if (key.contains('diagn')) return Icons.monitor_heart_outlined;
    if (key.contains('dental')) return Icons.medication_liquid_outlined;
    if (key.contains('cardio')) return Icons.favorite_outline_rounded;
    if (key.contains('emergency')) return Icons.medical_services_outlined;
    if (key.contains('lab')) return Icons.science_outlined;
    if (key.contains('medic') || key.contains('pharma')) {
      return Icons.medication_outlined;
    }
    if (key.contains('dispos')) return Icons.inventory_2_outlined;
    return Icons.category_outlined;
  }
}
