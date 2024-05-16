// Menu

import 'package:flutter/material.dart';
import 'package:gccontrol/theme/app_theme.dart';

class Menu extends StatelessWidget {
  final String activeItem;
  final Function(String) onItemPressed;

  const Menu({
    super.key,
    required this.activeItem,
    required this.onItemPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _menuItem(
                title: 'Home',
                isActive: activeItem == 'Home',
                onTap: () => onItemPressed('Home'),
              ),
              _menuItem(
                title: 'Sobre nós',
                isActive: activeItem == 'Sobre nós',
                onTap: () => onItemPressed('Sobre nós'),
              ),
              _menuItem(
                title: 'Contate-nos',
                isActive: activeItem == 'Contate-nos',
                onTap: () => onItemPressed('Contate-nos'),
              ),
              _menuItem(
                title: 'Ajuda',
                isActive: activeItem == 'Ajuda',
                onTap: () => onItemPressed('Ajuda'),
              ),
            ],
          ),
          Row(
            children: [
              _menuItem(
                title: 'Entrar',
                isActive: activeItem == 'Entrar',
                onTap: () => onItemPressed('Entrar'),
              ),
              _menuItem(
                title: 'Cadastrar',
                isActive: activeItem == 'Cadastrar',
                onTap: () => onItemPressed('Cadastrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 75),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isActive ? AppTheme.colors.primary : AppTheme.colors.menu,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              isActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
