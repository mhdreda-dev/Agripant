import 'package:flutter/material.dart';

class ExpertFilterWidget extends StatelessWidget {
  final Function(String) onSpecialitySelected;
  final String? selectedSpeciality;

  const ExpertFilterWidget({
    Key? key,
    required this.onSpecialitySelected,
    this.selectedSpeciality,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Liste des spécialités disponibles
    final List<String> specialities = [
      'Agriculture de précision',
      'Irrigation',
      'Élevage durable',
      'Permaculture',
      'Semences et Génétique',
      'Agriculture urbaine',
      'Viticulture',
      'Agroécologie',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Filtrer par spécialité',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specialities.length,
            itemBuilder: (context, index) {
              final speciality = specialities[index];
              final isSelected = selectedSpeciality == speciality;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(speciality),
                  selected: isSelected,
                  onSelected: (_) => onSpecialitySelected(speciality),
                  checkmarkColor: Colors.white,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 12,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
