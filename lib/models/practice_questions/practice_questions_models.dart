import 'package:flutter/foundation.dart';

/// Subject model (UI-first).
@immutable
class Subject {
  final String id;
  final String name;
  final List<Unit> units;

  const Subject({
    required this.id,
    required this.name,
    required this.units,
  });
}

/// Unit model (UI-first).
@immutable
class Unit {
  final String id;
  final String name;
  final List<Chapter> chapters;

  const Unit({
    required this.id,
    required this.name,
    required this.chapters,
  });
}

/// Chapter model (UI-first).
@immutable
class Chapter {
  final String id;
  final String name;

  const Chapter({
    required this.id,
    required this.name,
  });
}

/// Deterministic fallback syllabus (used if backend calls fail).
/// IMPORTANT: This is only used to keep UI functioning while backend chapter listing
/// is not available.
final List<Subject> mockSyllabus = mockSyllabusByClass['Class 11'] ?? const [];

/// Class-wise mock syllabus used by the UI until API is connected.
final Map<String, List<Subject>> mockSyllabusByClass = {
  'Class 9': [
    // -------------------- Mathematics --------------------
    Subject(
      id: 'sub-class9-math',
      name: 'Mathematics',
      units: [
        Unit(
          id: 'c9-unit-math-1',
          name: 'Number Systems',
          chapters: [
            Chapter(id: 'c9-ch-math-1', name: 'Laws of Exponents'),
            Chapter(id: 'c9-ch-math-2', name: 'Number Systems'),
          ],
        ),
        Unit(
          id: 'c9-unit-math-2',
          name: 'Algebra',
          chapters: [
            Chapter(id: 'c9-ch-math-3', name: 'Polynomials'),
            Chapter(id: 'c9-ch-math-4', name: 'Factorisation'),
            Chapter(
                id: 'c9-ch-math-5',
                name: 'Linear Equations in Two Variables'),
            Chapter(id: 'c9-ch-math-6', name: 'Quadratic Equations'),
          ],
        ),
        Unit(
          id: 'c9-unit-math-3',
          name: 'Geometry',
          chapters: [
            Chapter(id: 'c9-ch-math-7', name: 'Triangles'),
            Chapter(id: 'c9-ch-math-8', name: 'Coordinate Geometry'),
            Chapter(id: 'c9-ch-math-9', name: 'Lines and Angles'),
            Chapter(id: 'c9-ch-math-10', name: 'Circles'),
          ],
        ),
        Unit(
          id: 'c9-unit-math-4',
          name: 'Mensuration & Statistics',
          chapters: [
            Chapter(
                id: 'c9-ch-math-11',
                name: 'Areas of Parallelograms and Triangles'),
            Chapter(
                id: 'c9-ch-math-12',
                name: 'Surface Areas and Volumes'),
            Chapter(id: 'c9-ch-math-13', name: 'Statistics'),
          ],
        ),
        Unit(
          id: 'c9-unit-math-5',
          name: 'Application of Maths',
          chapters: [
            Chapter(id: 'c9-ch-math-14', name: 'Heron’s Formula'),
            Chapter(id: 'c9-ch-math-15', name: 'Probability'),
          ],
        ),
      ],
    ),

    // -------------------- Science --------------------
    Subject(
      id: 'sub-class9-science',
      name: 'Science',
      units: [
        Unit(
          id: 'c9-unit-sci-1',
          name: 'Physics',
          chapters: [
            Chapter(id: 'c9-ch-sci-1', name: 'Motion'),
            Chapter(id: 'c9-ch-sci-2', name: 'Force and Laws of Motion'),
            Chapter(id: 'c9-ch-sci-3', name: 'Work and Energy'),
            Chapter(id: 'c9-ch-sci-4', name: 'Sound'),
          ],
        ),
        Unit(
          id: 'c9-unit-sci-2',
          name: 'Chemistry',
          chapters: [
            Chapter(id: 'c9-ch-sci-5', name: 'Matter in Our Surroundings'),
            Chapter(id: 'c9-ch-sci-6', name: 'Is Matter Around Us Pure?'),
            Chapter(id: 'c9-ch-sci-7', name: 'Structure of the Atom'),
          ],
        ),
        Unit(
          id: 'c9-unit-sci-3',
          name: 'Biology',
          chapters: [
            Chapter(
                id: 'c9-ch-sci-8', name: 'The Fundamental Unit of Life'),
            Chapter(id: 'c9-ch-sci-9', name: 'Tissues'),
            Chapter(
                id: 'c9-ch-sci-10',
                name: 'Diversity in Living Organisms'),
          ],
        ),
        Unit(
          id: 'c9-unit-sci-4',
          name: 'Natural Phenomena',
          chapters: [
            Chapter(
                id: 'c9-ch-sci-11',
                name: 'Improvement in Food Resources'),
            Chapter(id: 'c9-ch-sci-12', name: 'Why Do We Fall Ill?'),
            Chapter(id: 'c9-ch-sci-13', name: 'Natural Resources'),
          ],
        ),
      ],
    ),

    // -------------------- English --------------------
    Subject(
      id: 'sub-class9-eng',
      name: 'English',
      units: [
        Unit(
          id: 'c9-unit-eng-1',
          name: 'Literature (Beehive)',
          chapters: [
            Chapter(id: 'c9-ch-eng-1', name: 'The Road Not Taken'),
            Chapter(id: 'c9-ch-eng-2', name: 'The Lost Child'),
            Chapter(id: 'c9-ch-eng-3', name: 'The Adventures of Toto'),
            Chapter(id: 'c9-ch-eng-4', name: 'A Truly Beautiful Mind'),
          ],
        ),
        Unit(
          id: 'c9-unit-eng-2',
          name: 'Supplementary (Moments)',
          chapters: [
            Chapter(id: 'c9-ch-eng-5', name: 'Weathering the Storm in Ersama'),
            Chapter(id: 'c9-ch-eng-6', name: 'The Last Leaf'),
            Chapter(id: 'c9-ch-eng-7', name: 'A House is Not a Home'),
            Chapter(id: 'c9-ch-eng-8', name: 'If I Were You'),
          ],
        ),
      ],
    ),

    // -------------------- Social Science --------------------
    Subject(
      id: 'sub-class9-sci',
      name: 'Social Science',
      units: [
        Unit(
          id: 'c9-unit-soc-1',
          name: 'History',
          chapters: [
            Chapter(id: 'c9-ch-soc-1', name: 'The French Revolution'),
            Chapter(
                id: 'c9-ch-soc-2',
                name: 'Nazism and the Rise of Hitler'),
          ],
        ),
        Unit(
          id: 'c9-unit-soc-2',
          name: 'Geography',
          chapters: [
            Chapter(
                id: 'c9-ch-soc-3',
                name: 'India and the Contemporary World'),
            Chapter(id: 'c9-ch-soc-4', name: 'India: Size and Location'),
            Chapter(
                id: 'c9-ch-soc-5', name: 'Physical Features of India'),
          ],
        ),
        Unit(
          id: 'c9-unit-soc-3',
          name: 'Civics & Economics',
          chapters: [
            Chapter(
                id: 'c9-ch-soc-6',
                name: 'What is Democracy? Why Democracy?'),
            Chapter(
                id: 'c9-ch-soc-7',
                name: 'Socialism in the 20th Century'),
          ],
        ),
      ],
    ),

    // -------------------- Hindi --------------------
    Subject(
      id: 'sub-class9-hindi',
      name: 'Hindi',
      units: [
        Unit(
          id: 'c9-unit-hi-1',
          name: 'काव्य-खंड (Poetry)',
          chapters: [
            Chapter(id: 'c9-ch-hi-1', name: 'प्रश्न और उत्तर'),
            Chapter(id: 'c9-ch-hi-2', name: 'दसवीं का चाँद'),
          ],
        ),
        Unit(
          id: 'c9-unit-hi-2',
          name: 'गद्य-खंड (Prose)',
          chapters: [
            Chapter(id: 'c9-ch-hi-3', name: 'नेमि-नियम'),
            Chapter(id: 'c9-ch-hi-4', name: 'कबीर'),
          ],
        ),
      ],
    ),
  ],

  'Class 10': [
    Subject(
      id: 'sub-class10-math',
      name: 'Mathematics',
      units: [
        Unit(
          id: 'c10-unit-math-1',
          name: 'Algebra',
          chapters: [
            Chapter(id: 'c10-ch-math-1', name: 'Real Numbers'),
            Chapter(id: 'c10-ch-math-2', name: 'Polynomials'),
            Chapter(
                id: 'c10-ch-math-3',
                name: 'Pair of Linear Equations in Two Variables'),
            Chapter(id: 'c10-ch-math-4', name: 'Quadratic Equations'),
          ],
        ),
        Unit(
          id: 'c10-unit-math-2',
          name: 'Trigonometry',
          chapters: [
            Chapter(id: 'c10-ch-math-5', name: 'Trigonometric Ratios'),
            Chapter(id: 'c10-ch-math-6', name: 'Trigonometric Identities'),
            Chapter(id: 'c10-ch-math-7', name: 'Heights and Distances'),
          ],
        ),
        Unit(
          id: 'c10-unit-math-3',
          name: 'Geometry',
          chapters: [
            Chapter(id: 'c10-ch-math-8', name: 'Triangles'),
            Chapter(id: 'c10-ch-math-9', name: 'Circles'),
            Chapter(id: 'c10-ch-math-10', name: 'Areas Related to Circles'),
          ],
        ),
        Unit(
          id: 'c10-unit-math-4',
          name: 'Mensuration & Statistics',
          chapters: [
            Chapter(id: 'c10-ch-math-11', name: 'Probability'),
            Chapter(id: 'c10-ch-math-12', name: 'Statistics'),
            Chapter(
                id: 'c10-ch-math-13',
                name: 'Surface Areas and Volumes'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class10-science',
      name: 'Science',
      units: [
        Unit(
          id: 'c10-unit-sci-1',
          name: 'Physics',
          chapters: [
            Chapter(
                id: 'c10-ch-sci-1',
                name: 'Light — Reflection and Refraction'),
            Chapter(
                id: 'c10-ch-sci-2',
                name: 'Human Eye and the Colourful World'),
            Chapter(id: 'c10-ch-sci-3', name: 'Electricity'),
          ],
        ),
        Unit(
          id: 'c10-unit-sci-2',
          name: 'Chemistry',
          chapters: [
            Chapter(
                id: 'c10-ch-sci-4',
                name: 'Chemical Reactions and Equations'),
            Chapter(id: 'c10-ch-sci-5', name: 'Metals and Non-metals'),
            Chapter(
                id: 'c10-ch-sci-6',
                name: 'Carbon and its Compounds'),
          ],
        ),
        Unit(
          id: 'c10-unit-sci-3',
          name: 'Biology',
          chapters: [
            Chapter(id: 'c10-ch-sci-7', name: 'Life Processes'),
            Chapter(id: 'c10-ch-sci-8', name: 'Control and Coordination'),
            Chapter(id: 'c10-ch-sci-9', name: 'How do Organisms Reproduce?'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class10-eng',
      name: 'English',
      units: [
        Unit(
          id: 'c10-unit-eng-1',
          name: 'Literature (First Flight)',
          chapters: [
            Chapter(id: 'c10-ch-eng-1', name: 'Dust of Snow'),
            Chapter(id: 'c10-ch-eng-2', name: 'Fire and Ice'),
            Chapter(id: 'c10-ch-eng-3', name: 'The Making of a Scientist'),
            Chapter(id: 'c10-ch-eng-4', name: 'A Thing of Beauty'),
          ],
        ),
        Unit(
          id: 'c10-unit-eng-2',
          name: 'Supplementary (Footprints Without Feet)',
          chapters: [
            Chapter(id: 'c10-ch-eng-5', name: 'A Triumph of Surgery'),
            Chapter(id: 'c10-ch-eng-6', name: 'The Thief’s Story'),
            Chapter(id: 'c10-ch-eng-7', name: 'The Midnight Visitor'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class10-soc',
      name: 'Social Science',
      units: [
        Unit(
          id: 'c10-unit-soc-1',
          name: 'History (India & the Contemporary World)',
          chapters: [
            Chapter(
                id: 'c10-ch-soc-1',
                name: 'The Rise of Nationalism in Europe'),
            Chapter(id: 'c10-ch-soc-2', name: 'Nationalism in India'),
          ],
        ),
        Unit(
          id: 'c10-unit-soc-2',
          name: 'Geography (Contemporary India)',
          chapters: [
            Chapter(id: 'c10-ch-soc-3', name: 'Resources and Development'),
            Chapter(
                id: 'c10-ch-soc-4',
                name: 'Forest and Wildlife Resources'),
            Chapter(id: 'c10-ch-soc-5', name: 'Water Resources'),
          ],
        ),
        Unit(
          id: 'c10-unit-soc-3',
          name: 'Civics & Economics',
          chapters: [
            Chapter(id: 'c10-ch-soc-6', name: 'Democratic Politics'),
            Chapter(
                id: 'c10-ch-soc-7',
                name: 'Understanding Economic Development'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class10-hindi',
      name: 'Hindi',
      units: [
        Unit(
          id: 'c10-unit-hi-1',
          name: 'काव्य-खंड',
          chapters: [
            Chapter(id: 'c10-ch-hi-1', name: 'साखियाँ एवं सबद'),
            Chapter(id: 'c10-ch-hi-2', name: 'पहलवान की ढोलक'),
          ],
        ),
        Unit(
          id: 'c10-unit-hi-2',
          name: 'गद्य-खंड',
          chapters: [
            Chapter(id: 'c10-ch-hi-3', name: 'बड़े भाई साहब'),
            Chapter(id: 'c10-ch-hi-4', name: 'टोपी'),
          ],
        ),
      ],
    ),
  ],

  // For Class 11 & 12, keep existing content exactly as in the broken file.
  // NOTE: These are large; they were already present and are preserved.
  // The UI expects mockSyllabusByClass to exist.
  'Class 11': [
    // Common core for CBSE Class 11 (stream-dependent in reality).
    Subject(
      id: 'sub-class11-math',
      name: 'Mathematics',
      units: [
        Unit(
          id: 'c11-unit-math-1',
          name: 'Relations & Functions',
          chapters: [
            Chapter(id: 'c11-ch-math-1', name: 'Sets'),
            Chapter(id: 'c11-ch-math-2', name: 'Relations and Functions'),
          ],
        ),
        Unit(
          id: 'c11-unit-math-2',
          name: 'Algebra',
          chapters: [
            Chapter(
                id: 'c11-ch-math-3',
                name: 'Complex Numbers and Quadratic Equations'),
            Chapter(id: 'c11-ch-math-4', name: 'Linear Inequalities'),
            Chapter(id: 'c11-ch-math-5', name: 'Mathematical Induction'),
          ],
        ),
        Unit(
          id: 'c11-unit-math-3',
          name: 'Calculus',
          chapters: [
            Chapter(id: 'c11-ch-math-6', name: 'Limits'),
            Chapter(id: 'c11-ch-math-7', name: 'Derivatives'),
            Chapter(id: 'c11-ch-math-8', name: 'Integrals'),
          ],
        ),
        Unit(
          id: 'c11-unit-math-4',
          name: 'Vectors & Trigonometry',
          chapters: [
            Chapter(id: 'c11-ch-math-9', name: 'Vectors'),
            Chapter(id: 'c11-ch-math-10', name: 'Trigonometric Functions'),
          ],
        ),
        Unit(
          id: 'c11-unit-math-5',
          name: 'Linear Programming & Statistics',
          chapters: [
            Chapter(id: 'c11-ch-math-11', name: 'Linear Programming'),
            Chapter(id: 'c11-ch-math-12', name: 'Statistics'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-physics',
      name: 'Physics',
      units: [
        Unit(
          id: 'c11-unit-phy-1',
          name: 'Kinematics & Laws',
          chapters: [
            Chapter(id: 'c11-ch-phy-1', name: 'Motion in a Straight Line'),
            Chapter(id: 'c11-ch-phy-2', name: 'Motion in a Plane'),
            Chapter(id: 'c11-ch-phy-3', name: 'Laws of Motion'),
          ],
        ),
        Unit(
          id: 'c11-unit-phy-2',
          name: 'Work, Energy & Power',
          chapters: [
            Chapter(
                id: 'c11-ch-phy-4', name: 'Work, Energy and Power'),
            Chapter(id: 'c11-ch-phy-5', name: 'Rotational Motion'),
          ],
        ),
        Unit(
          id: 'c11-unit-phy-3',
          name: 'Gravitation & Properties',
          chapters: [
            Chapter(id: 'c11-ch-phy-6', name: 'Gravitation'),
            Chapter(
                id: 'c11-ch-phy-7',
                name: 'Mechanical Properties of Solids'),
            Chapter(
                id: 'c11-ch-phy-8',
                name: 'Thermal Properties of Matter'),
          ],
        ),
        Unit(
          id: 'c11-unit-phy-4',
          name: 'Waves & Optics',
          chapters: [
            Chapter(id: 'c11-ch-phy-9', name: 'Waves'),
            Chapter(id: 'c11-ch-phy-10', name: 'Sound Waves'),
            Chapter(
                id: 'c11-ch-phy-11',
                name: 'Ray Optics and Optical Instruments'),
          ],
        ),
        Unit(
          id: 'c11-unit-phy-5',
          name: 'Electrostatics & Current',
          chapters: [
            Chapter(id: 'c11-ch-phy-12', name: 'Electrostatics'),
            Chapter(id: 'c11-ch-phy-13', name: 'Current Electricity'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-chem',
      name: 'Chemistry',
      units: [
        Unit(
          id: 'c11-unit-chem-1',
          name: 'Some Basic Concepts',
          chapters: [
            Chapter(
                id: 'c11-ch-chem-1',
                name: 'Some Basic Concepts of Chemistry'),
            Chapter(id: 'c11-ch-chem-2', name: 'Structure of Atom'),
          ],
        ),
        Unit(
          id: 'c11-unit-chem-2',
          name: 'Classification & Equilibrium',
          chapters: [
            Chapter(
                id: 'c11-ch-chem-3',
                name:
                    'Chemical Classification of Elements and Periodicity of Properties'),
            Chapter(
                id: 'c11-ch-chem-4',
                name: 'Chemical Bonding and Molecular Structure'),
            Chapter(id: 'c11-ch-chem-5', name: 'States of Matter'),
            Chapter(id: 'c11-ch-chem-6', name: 'Thermodynamics'),
          ],
        ),
        Unit(
          id: 'c11-unit-chem-3',
          name: 'Organic Chemistry',
          chapters: [
            Chapter(id: 'c11-ch-chem-7', name: 'Hydrocarbons'),
            Chapter(id: 'c11-ch-chem-8', name: 'Haloalkanes and Haloarenes'),
          ],
        ),
        Unit(
          id: 'c11-unit-chem-4',
          name: 'Metallurgy & Solutions',
          chapters: [
            Chapter(id: 'c11-ch-chem-9', name: 'Metallurgy'),
            Chapter(id: 'c11-ch-chem-10', name: 'Solutions'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-bio',
      name: 'Biology',
      units: [
        Unit(
          id: 'c11-unit-bio-1',
          name: 'Cell & Genetics',
          chapters: [
            Chapter(id: 'c11-ch-bio-1', name: 'Cell: The Unit of Life'),
            Chapter(id: 'c11-ch-bio-2', name: 'Biomolecules'),
            Chapter(id: 'c11-ch-bio-3', name: 'Genetics and Evolution'),
          ],
        ),
        Unit(
          id: 'c11-unit-bio-2',
          name: 'Plant Physiology',
          chapters: [
            Chapter(id: 'c11-ch-bio-4', name: 'Plant Kingdom'),
            Chapter(
                id: 'c11-ch-bio-5',
                name: 'Morphology of Flowering Plants'),
            Chapter(
                id: 'c11-ch-bio-6',
                name: 'Structural Organisation in Plants'),
          ],
        ),
        Unit(
          id: 'c11-unit-bio-3',
          name: 'Human Physiology & Health',
          chapters: [
            Chapter(id: 'c11-ch-bio-7', name: 'Human Physiology'),
            Chapter(id: 'c11-ch-bio-8', name: 'Reproduction'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-cs',
      name: 'Computer Science',
      units: [
        Unit(
          id: 'c11-unit-cs-1',
          name: 'Fundamentals',
          chapters: [
            Chapter(id: 'c11-ch-cs-1', name: 'Computer Systems'),
            Chapter(
                id: 'c11-ch-cs-2',
                name: 'Programming Languages and Translators'),
          ],
        ),
        Unit(
          id: 'c11-unit-cs-2',
          name: 'Programming',
          chapters: [
            Chapter(id: 'c11-ch-cs-3', name: 'Basics of Python'),
            Chapter(id: 'c11-ch-cs-4', name: 'Control Statements'),
          ],
        ),
        Unit(
          id: 'c11-unit-cs-3',
          name: 'Data Handling',
          chapters: [
            Chapter(id: 'c11-ch-cs-5', name: 'Strings'),
            Chapter(
                id: 'c11-ch-cs-6',
                name: 'Lists, Tuples, and Dictionaries'),
          ],
        ),
        Unit(
          id: 'c11-unit-cs-4',
          name: 'Algorithms & Complexity',
          chapters: [
            Chapter(id: 'c11-ch-cs-7', name: 'Algorithmic Complexity'),
            Chapter(id: 'c11-ch-cs-8', name: 'Sorting Algorithms'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-eng',
      name: 'English',
      units: [
        Unit(
          id: 'c11-unit-eng-1',
          name: 'Reading & Literature',
          chapters: [
            Chapter(id: 'c11-ch-eng-1', name: 'The Portrait of a Lady'),
            Chapter(id: 'c11-ch-eng-2', name: 'We’re Not Afraid to Die...'),
            Chapter(
                id: 'c11-ch-eng-3',
                name: 'The Summer of the Beautiful White Horse'),
          ],
        ),
        Unit(
          id: 'c11-unit-eng-2',
          name: 'Grammar & Writing',
          chapters: [
            Chapter(
                id: 'c11-ch-eng-4',
                name: 'The Sound of Music (Reading)'),
            Chapter(id: 'c11-ch-eng-5', name: 'Letter to a Friend'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-acct',
      name: 'Accountancy',
      units: [
        Unit(
          id: 'c11-unit-acct-1',
          name: 'Accounting Fundamentals',
          chapters: [
            Chapter(id: 'c11-ch-acct-1', name: 'Introduction to Accounting'),
            Chapter(id: 'c11-ch-acct-2', name: 'Basic Accounting Terms'),
          ],
        ),
        Unit(
          id: 'c11-unit-acct-2',
          name: 'Financial Statements',
          chapters: [
            Chapter(id: 'c11-ch-acct-3', name: 'Trial Balance'),
            Chapter(
                id: 'c11-ch-acct-4',
                name: 'Final Accounts of a Sole Proprietorship'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-bus',
      name: 'Business Studies',
      units: [
        Unit(
          id: 'c11-unit-bus-1',
          name: 'Business Environment',
          chapters: [
            Chapter(
                id: 'c11-ch-bus-1',
                name: 'Nature and Significance of Management'),
            Chapter(id: 'c11-ch-bus-2', name: 'Business Environment'),
          ],
        ),
        Unit(
          id: 'c11-unit-bus-2',
          name: 'Functions',
          chapters: [
            Chapter(id: 'c11-ch-bus-3', name: 'Principles of Management'),
            Chapter(id: 'c11-ch-bus-4', name: 'Business Finance and Trade'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-eco',
      name: 'Economics',
      units: [
        Unit(
          id: 'c11-unit-eco-1',
          name: 'Introductory Micro & Macro',
          chapters: [
            Chapter(id: 'c11-ch-eco-1', name: 'Introduction to Microeconomics'),
            Chapter(id: 'c11-ch-eco-2', name: 'Introduction to Macroeconomics'),
          ],
        ),
        Unit(
          id: 'c11-unit-eco-2',
          name: 'Market & Policies',
          chapters: [
            Chapter(id: 'c11-ch-eco-3', name: 'Demand and Supply'),
            Chapter(id: 'c11-ch-eco-4', name: 'National Income'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class11-pol',
      name: 'Political Science',
      units: [
        Unit(
          id: 'c11-unit-pol-1',
          name: 'Constitution & Democracy',
          chapters: [
            Chapter(id: 'c11-ch-pol-1', name: 'Constitutional Design'),
            Chapter(id: 'c11-ch-pol-2', name: 'Democracy in the Modern World'),
          ],
        ),
        Unit(
          id: 'c11-unit-pol-2',
          name: 'Politics in India',
          chapters: [
            Chapter(id: 'c11-ch-pol-3', name: 'Politics in India'),
            Chapter(id: 'c11-ch-pol-4', name: 'Elections'),
          ],
        ),
      ],
    ),
  ],

  'Class 12': [
    Subject(
      id: 'sub-class12-math',
      name: 'Mathematics',
      units: [
        Unit(
          id: 'c12-unit-math-1',
          name: 'Algebra',
          chapters: [
            Chapter(id: 'c12-ch-math-1', name: 'Relations and Functions'),
            Chapter(id: 'c12-ch-math-2', name: 'Inverse Trigonometric Functions'),
          ],
        ),
        Unit(
          id: 'c12-unit-math-2',
          name: 'Calculus',
          chapters: [
            Chapter(
                id: 'c12-ch-math-3',
                name: 'Applications of Derivatives'),
            Chapter(id: 'c12-ch-math-4', name: 'Integrals'),
          ],
        ),
        Unit(
          id: 'c12-unit-math-3',
          name: 'Vectors & 3D Geometry',
          chapters: [
            Chapter(id: 'c12-ch-math-5', name: 'Vectors'),
            Chapter(id: 'c12-ch-math-6', name: 'Three Dimensional Geometry'),
          ],
        ),
        Unit(
          id: 'c12-unit-math-4',
          name: 'Probability',
          chapters: [
            Chapter(id: 'c12-ch-math-7', name: 'Probability'),
            Chapter(id: 'c12-ch-math-8', name: 'Linear Programming'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-physics',
      name: 'Physics',
      units: [
        Unit(
          id: 'c12-unit-phy-1',
          name: 'Electrostatics & Circuits',
          chapters: [
            Chapter(
                id: 'c12-ch-phy-1',
                name: 'Electric Charges and Fields'),
            Chapter(
                id: 'c12-ch-phy-2',
                name: 'Electrostatic Potential and Capacitance'),
            Chapter(id: 'c12-ch-phy-3', name: 'Current Electricity'),
          ],
        ),
        Unit(
          id: 'c12-unit-phy-2',
          name: 'Magnetism & EM Induction',
          chapters: [
            Chapter(
                id: 'c12-ch-phy-4',
                name: 'Moving Charges and Magnetism'),
            Chapter(
                id: 'c12-ch-phy-5',
                name: 'Magnetism and Matter'),
            Chapter(
                id: 'c12-ch-phy-6',
                name: 'Electromagnetic Induction'),
          ],
        ),
        Unit(
          id: 'c12-unit-phy-3',
          name: 'Optics & Modern Physics',
          chapters: [
            Chapter(
                id: 'c12-ch-phy-7',
                name: 'Ray Optics and Optical Instruments'),
            Chapter(id: 'c12-ch-phy-8', name: 'Wave Optics'),
            Chapter(
                id: 'c12-ch-phy-9',
                name: 'Dual Nature of Matter and Radiation'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-chem',
      name: 'Chemistry',
      units: [
        Unit(
          id: 'c12-unit-chem-1',
          name: 'Chemical Kinetics & Equilibrium',
          chapters: [
            Chapter(id: 'c12-ch-chem-1', name: 'Solid State'),
            Chapter(id: 'c12-ch-chem-2', name: 'Surface Chemistry'),
            Chapter(id: 'c12-ch-chem-3', name: 'Chemical Kinetics'),
            Chapter(id: 'c12-ch-chem-4', name: 'Equilibrium'),
          ],
        ),
        Unit(
          id: 'c12-unit-chem-2',
          name: 'Electrochemistry & Metals',
          chapters: [
            Chapter(id: 'c12-ch-chem-5', name: 'Electrochemistry'),
            Chapter(id: 'c12-ch-chem-6', name: 'Metallurgy'),
          ],
        ),
        Unit(
          id: 'c12-unit-chem-3',
          name: 'Organic Chemistry',
          chapters: [
            Chapter(
                id: 'c12-ch-chem-7',
                name: 'Aldehydes, Ketones and Carboxylic Acids'),
            Chapter(id: 'c12-ch-chem-8', name: 'Amines'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-bio',
      name: 'Biology',
      units: [
        Unit(
          id: 'c12-unit-bio-1',
          name: 'Reproduction & Genetics',
          chapters: [
            Chapter(id: 'c12-ch-bio-1', name: 'Reproduction'),
            Chapter(id: 'c12-ch-bio-2', name: 'Genetics and Evolution'),
          ],
        ),
        Unit(
          id: 'c12-unit-bio-2',
          name: 'Ecology & Environment',
          chapters: [
            Chapter(id: 'c12-ch-bio-3', name: 'Ecology'),
            Chapter(id: 'c12-ch-bio-4', name: 'Environmental Issues'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-cs',
      name: 'Computer Science',
      units: [
        Unit(
          id: 'c12-unit-cs-1',
          name: 'Data Structures',
          chapters: [
            Chapter(id: 'c12-ch-cs-1', name: 'Arrays'),
            Chapter(id: 'c12-ch-cs-2', name: 'Stacks and Queues'),
            Chapter(id: 'c12-ch-cs-3', name: 'Trees'),
          ],
        ),
        Unit(
          id: 'c12-unit-cs-2',
          name: 'Database & Networking',
          chapters: [
            Chapter(
                id: 'c12-ch-cs-4',
                name: 'Relational Database Concepts'),
            Chapter(id: 'c12-ch-cs-5', name: 'Networking'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-eng',
      name: 'English',
      units: [
        Unit(
          id: 'c12-unit-eng-1',
          name: 'Literature (Flamingo & Vistas)',
          chapters: [
            Chapter(id: 'c12-ch-eng-1', name: 'Keeping Quiet'),
            Chapter(id: 'c12-ch-eng-2', name: 'Going Places'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-acct',
      name: 'Accountancy',
      units: [
        Unit(
          id: 'c12-unit-acct-1',
          name: 'Partnership Accounts',
          chapters: [
            Chapter(id: 'c12-ch-acct-1', name: 'Partnership: Fundamentals'),
            Chapter(
                id: 'c12-ch-acct-2',
                name: 'Reconstitution of Firms'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-bus',
      name: 'Business Studies',
      units: [
        Unit(
          id: 'c12-unit-bus-1',
          name: 'Marketing & Finance',
          chapters: [
            Chapter(id: 'c12-ch-bus-1', name: 'Marketing'),
            Chapter(id: 'c12-ch-bus-2', name: 'Financial Management'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-eco',
      name: 'Economics',
      units: [
        Unit(
          id: 'c12-unit-eco-1',
          name: 'Indian Economy',
          chapters: [
            Chapter(id: 'c12-ch-eco-1', name: 'National Income'),
            Chapter(id: 'c12-ch-eco-2', name: 'Money and Banking'),
          ],
        ),
      ],
    ),

    Subject(
      id: 'sub-class12-pol',
      name: 'Political Science',
      units: [
        Unit(
          id: 'c12-unit-pol-1',
          name: 'Politics & Government',
          chapters: [
            Chapter(
                id: 'c12-ch-pol-1',
                name: 'Popular Struggles and Movements'),
            Chapter(
                id: 'c12-ch-pol-2',
                name: 'Democracy and Diversity'),
          ],
        ),
      ],
    ),
  ],
};

