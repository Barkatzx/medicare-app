import 'package:flutter/material.dart';

import '/core/style/text_styles.dart';

class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Heading 1', style: AppTextStyles.heading1),
        Text('Body Text', style: AppTextStyles.bodyMedium),
        Text('Product Price', style: AppTextStyles.productPrice(context)),
        ElevatedButton(
          onPressed: () {},
          child: Text('Add to Cart'),
          // Button text will automatically use buttonText style
        ),
      ],
    );
  }
}
