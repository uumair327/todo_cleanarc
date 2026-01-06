import 'package:flutter/material.dart';
import 'build_context_color_extension.dart';

/// Demo widget showcasing the semantic color system integration
/// 
/// This widget demonstrates how to use the BuildContextColorExtension
/// and AppColorExtension to access semantic colors in a type-safe manner.
class ThemeDemoWidget extends StatelessWidget {
  const ThemeDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semantic Color System Demo'),
        backgroundColor: context.surfacePrimary,
        foregroundColor: context.onSurfacePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Surface colors demonstration
            _buildSectionTitle(context, 'Surface Colors'),
            _buildSurfaceColorsDemo(context),
            
            const SizedBox(height: 24),
            
            // Task category colors demonstration
            _buildSectionTitle(context, 'Task Category Colors'),
            _buildTaskCategoryColorsDemo(context),
            
            const SizedBox(height: 24),
            
            // State colors demonstration
            _buildSectionTitle(context, 'State Colors'),
            _buildStateColorsDemo(context),
            
            const SizedBox(height: 24),
            
            // Opacity variants demonstration
            _buildSectionTitle(context, 'Opacity Variants'),
            _buildOpacityVariantsDemo(context),
            
            const SizedBox(height: 24),
            
            // Dynamic color selection demonstration
            _buildSectionTitle(context, 'Dynamic Color Selection'),
            _buildDynamicColorDemo(context),
            
            const SizedBox(height: 24),
            
            // Material 3 integration demonstration
            _buildSectionTitle(context, 'Material 3 Integration'),
            _buildMaterial3Demo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: context.onSurfacePrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSurfaceColorsDemo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildColorCard(
            context,
            'Primary Surface',
            context.surfacePrimary,
            context.onSurfacePrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildColorCard(
            context,
            'Secondary Surface',
            context.surfaceSecondary,
            context.onSurfaceSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildColorCard(
            context,
            'Tertiary Surface',
            context.surfaceTertiary,
            context.onSurfaceSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCategoryColorsDemo(BuildContext context) {
    final taskStatuses = ['ongoing', 'inprocess', 'completed', 'canceled'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: taskStatuses.map((status) {
        final colorPair = context.getTaskColorPair(status);
        return _buildColorChip(
          context,
          status.toUpperCase(),
          colorPair.background,
          colorPair.text,
        );
      }).toList(),
    );
  }

  Widget _buildStateColorsDemo(BuildContext context) {
    final states = ['success', 'warning', 'error', 'info'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: states.map((state) {
        final colorPair = context.getStateColorPair(state);
        return _buildColorChip(
          context,
          state.toUpperCase(),
          colorPair.background,
          colorPair.text,
        );
      }).toList(),
    );
  }

  Widget _buildOpacityVariantsDemo(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildColorCard(
                context,
                'Surface 50%',
                context.surfacePrimaryOpacity50,
                context.onSurfacePrimary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard(
                context,
                'Surface 75%',
                context.surfacePrimaryOpacity75,
                context.onSurfacePrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildColorCard(
                context,
                'Text 40%',
                context.surfacePrimary,
                context.onSurfacePrimaryOpacity40,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildColorCard(
                context,
                'Text 60%',
                context.surfacePrimary,
                context.onSurfacePrimaryOpacity60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicColorDemo(BuildContext context) {
    return Column(
      children: [
        // Task status dropdown demo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.onSurfacePrimaryOpacity40),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dynamic Task Status Colors',
                style: TextStyle(
                  color: context.onSurfaceSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Colors automatically adapt based on task status',
                style: TextStyle(
                  color: context.onSurfaceSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Accessibility demo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.infoBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.accessibility,
                color: context.onInfoBackground,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accessibility Compliant',
                      style: TextStyle(
                        color: context.onInfoBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'All color combinations meet WCAG AA standards',
                      style: TextStyle(
                        color: context.onInfoBackground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterial3Demo(BuildContext context) {
    return Column(
      children: [
        // Material 3 buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('Filled'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Material 3 card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Material 3 Card',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Automatically styled with semantic colors',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Action'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorCard(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.onSurfacePrimaryOpacity40,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '#${((backgroundColor.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((backgroundColor.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}${((backgroundColor.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(
    BuildContext context,
    String label,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}