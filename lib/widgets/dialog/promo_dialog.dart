import 'package:flutter/material.dart';

class PromoDialog extends StatelessWidget {
  const PromoDialog({super.key, this.imageUrl});
  final String? imageUrl;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: const DialogTheme(elevation: 0),
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShapeableImageView(
              image: NetworkImage(imageUrl ?? ''),
            ),

            // const SizedBox(height: 10),
            // SizedBox(
            //   width: 150,
            //   height: 40,
            //   child: ElevatedButton1(
            //     onclick: () {},
            //     text: 'Learn More',
            //     backgroundColor: Theme.of(context).primaryColor,
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),
            // Image.asset('assets/line.png',height: 50,color: Colors.white.withOpacity(0.8),),
            // SizedBox(height: 2,),
            SizedBox(
              width: 35,
              height: 35,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: Colors.grey.withAlpha( 80),
                mini: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ShapeableImageView extends StatelessWidget {
  final ImageProvider image;

  const ShapeableImageView({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image(
        image: image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/placeholder.png'),
      ),
    );
  }
}
