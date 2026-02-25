import os
import re

files_to_fix = [
    'lib/features/ask_doubts_screen.dart',
    'lib/features/courses/screens/my-courses/practice_screen.dart',
    'lib/features/courses/screens/my-courses/notes_screen.dart',
    'lib/features/courses/screens/my-courses/resources_screen.dart',
    'lib/features/courses/screens/my-courses/messages_screen.dart'
]

def process_file(filepath):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return

    with open(filepath, 'r') as f:
        content = f.read()

    replacements = [
        (r'backgroundColor:\s*Colors\.white', r'backgroundColor: Theme.of(context).extension<AppDesignExtension>()!.scaffoldBackgroundColor'),
        (r'color:\s*Colors\.white(?!.*\n.*color:\s*const\s*Color)', r'color: Theme.of(context).extension<AppDesignExtension>()!.cardColor'),
        
        (r'Color\(0xFF111827\)', r'Theme.of(context).colorScheme.onSurface'),
        (r'Color\(0xFF1F2937\)', r'Theme.of(context).colorScheme.onSurface'),
        (r'Color\(0xFF374151\)', r'Theme.of(context).extension<AppDesignExtension>()!.secondaryText'),
        (r'Color\(0xFF6B7280\)', r'Theme.of(context).extension<AppDesignExtension>()!.secondaryText'),
        (r'Color\(0xFF4B5563\)', r'Theme.of(context).extension<AppDesignExtension>()!.secondaryText'),
        (r'Color\(0xFF9CA3AF\)', r'Theme.of(context).extension<AppDesignExtension>()!.secondaryText'),
        (r'Color\(0xFFE5E7EB\)', r'Theme.of(context).extension<AppDesignExtension>()!.borderColor'),
        (r'Color\(0xFFF3F4F6\)', r'Theme.of(context).extension<AppDesignExtension>()!.skeletonBase'),
        (r'Color\(0xFFF9FAFB\)', r'Theme.of(context).extension<AppDesignExtension>()!.cardColor'), # Card backgrounds
        (r'Color\(0xFF0066FF\)', r'Theme.of(context).colorScheme.primary'),
        (r'Color\(0xFF2563EB\)', r'Theme.of(context).colorScheme.primary'),
        (r'Color\(0xFF3B82F6\)', r'Theme.of(context).colorScheme.primary'),
        (r'Color\(0xFFEFF6FF\)', r'Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)'),
        (r'Color\(0xFFDBEAFE\)', r'Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)'),
        
        (r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)'),
    ]

    new_content = content
    for pattern, rep_str in replacements:
        new_content = re.sub(pattern, rep_str, new_content)

    new_content = re.sub(r'color:\s*Theme\.of\(context\)\.extension<AppDesignExtension>\(\)!\.cardColor,\s*\n\s*fontSize:(.*?),', 
                         r'color: Colors.white,\n                                  fontSize:\1,', new_content)
    new_content = re.sub(r'color:\s*Theme\.of\(context\)\.extension<AppDesignExtension>\(\)!\.cardColor,\s*(.*?\n.*?)fontWeight:.*?bold', 
                         r'color: Colors.white, \1fontWeight: FontWeight.bold', new_content)

    if 'import \'package:flutter/material.dart\';' in new_content and 'theme.dart' not in new_content:
        if 'my-courses' in filepath:
            new_content = new_content.replace('import \'package:flutter/material.dart\';', 'import \'package:flutter/material.dart\';\nimport \'../../../../../theme.dart\';')
        else:
            new_content = new_content.replace('import \'package:flutter/material.dart\';', 'import \'package:flutter/material.dart\';\nimport \'../../theme.dart\';')

    with open(filepath, 'w') as f:
        f.write(new_content)
    print(f"Processed {filepath}")

for fp in files_to_fix:
    process_file(fp)
