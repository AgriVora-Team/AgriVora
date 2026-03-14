import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/agri_bottom_nav_bar.dart';

class CropOverviewPage extends StatelessWidget {

  final String name;
  final String scientific;
  final String image;

  const CropOverviewPage({
    super.key,
    required this.name,
    required this.scientific,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(

      backgroundColor: const Color(0xFFF2E8D5),

      body: Stack(
        children: [

          _background(),

          Positioned(
            top: MediaQuery.of(context).padding.top + 55,
            left: 24,
            right: 24,
            child: _header(),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _OverviewWaveClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.86,
                  padding: EdgeInsets.fromLTRB(16, 90, 16, bottomPad + 70),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E8D5).withOpacity(0.75),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),

                  child: _body(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/bg_fields.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _header() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0,2))
                  ],
                ),
              ),

              const SizedBox(height:6),

              Text(
                scientific,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height:8),

              _suitabilityBadge()

            ],
          ),
        ),

        _icon(),

      ],
    );
  }

  Widget _suitabilityBadge(){

    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),

      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(10),
      ),

      child: const Text(
        "85% Suitable",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _icon(){
    return Container(
      height:65,
      width:65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.spa,color:Colors.white,size:32),
    );
  }

  Widget _body(BuildContext context){

    return SingleChildScrollView(

      physics: const BouncingScrollPhysics(),

      child: Column(

        children: [

          _cropImage(),

          const SizedBox(height:16),

          _overview(),

          const SizedBox(height:16),

          _soilCompatibility(),

          const SizedBox(height:16),

          _soilNutrients(),

          const SizedBox(height:16),

          _climate(),

          const SizedBox(height:16),

          _growthTimeline(),

          const SizedBox(height:16),

          _yieldPrediction(),

          const SizedBox(height:16),

          _pestRisk(),

          const SizedBox(height:16),

          _farmingTips(),

          const SizedBox(height:20),

          _actions(context),

        ],
      ),
    );
  }

  Widget _cropImage(){

    return ClipRRect(

      borderRadius: BorderRadius.circular(18),

      child: Image.asset(
        image,
        height:150,
        width:double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _overview(){

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _title(Icons.info,"Crop Overview"),

          const SizedBox(height:10),

          Text(
            "$name ($scientific) is predicted as a suitable crop based on soil nutrients, pH levels and environmental conditions detected in your field.",
            style: const TextStyle(fontSize:13,height:1.4),
          ),

        ],
      ),
    );
  }

  Widget _soilCompatibility(){

    return _card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _title(Icons.landscape,"Soil Compatibility"),

          const SizedBox(height:12),

          _progress("pH Match",0.80),

          const SizedBox(height:10),

          _progress("Nitrogen Level",0.65),

        ],
      ),
    );
  }

  Widget _soilNutrients(){

    return _card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _title(Icons.science,"Soil Nutrients"),

          const SizedBox(height:12),

          _nutrient("Nitrogen","40 mg/kg"),
          _nutrient("Phosphorus","30 mg/kg"),
          _nutrient("Potassium","45 mg/kg"),

        ],
      ),
    );
  }

  Widget _climate(){

    return _card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _title(Icons.cloud,"Climate Suitability"),

          const SizedBox(height:10),

          const Text(
            "Weather conditions indicate favorable temperature and humidity levels for crop growth."
          ),

        ],
      ),
    );
  }

  Widget _growthTimeline(){

    return _card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _title(Icons.timeline,"Growth Timeline"),

          const SizedBox(height:10),

          _stage("Germination","7-10 days"),
          _stage("Vegetative Stage","30-40 days"),
          _stage("Flowering","20 days"),
          _stage("Harvest","90 days"),

        ],
      ),
    );
  }

  Widget _yieldPrediction(){

    return _card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _title(Icons.bar_chart,"Yield Prediction"),

          const SizedBox(height:10),

          const Text("Expected Yield: 4.5 tons per hectare"),

        ],
      ),
    );
  }

  Widget _pestRisk(){

    return _card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _title(Icons.bug_report,"Pest Risk"),

          const SizedBox(height:10),

          const Text("Moderate risk of leaf-eating insects. Regular monitoring recommended.")

        ],
      ),
    );
  }

  Widget _farmingTips(){

    return _card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          _title(Icons.lightbulb,"Farming Advice"),

          const SizedBox(height:10),

          _tip("Use balanced NPK fertilizer"),
          _tip("Drip irrigation improves water efficiency"),
          _tip("Monitor pests weekly"),

        ],
      ),
    );
  }

  Widget _actions(BuildContext context){

    return Column(

      children: [

        ElevatedButton(
          onPressed: (){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Saved to History"))
            );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
          ),

          child: const Text("Save Crop"),
        ),

        const SizedBox(height:12),

        ElevatedButton(
          onPressed: (){
            Navigator.pushNamed(context,'/ai_chat');
          },

          child: const Text("Ask AI"),
        ),

      ],
    );
  }

  Widget _title(IconData icon,String text){

    return Row(
      children: [

        Icon(icon,color: const Color(0xFF2E7D32)),

        const SizedBox(width:8),

        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize:17
          ),
        )

      ],
    );
  }

  Widget _progress(String label,double value){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(label),

        const SizedBox(height:6),

        LinearProgressIndicator(
          value:value,
          color: const Color(0xFF2E7D32),
          backgroundColor: Colors.black12,
        ),

      ],
    );
  }

  Widget _nutrient(String name,String value){

    return Padding(
      padding: const EdgeInsets.only(bottom:8),

      child: Row(
        children: [

          const Icon(Icons.circle,size:8,color:Colors.orange),

          const SizedBox(width:10),

          Text("$name : $value")

        ],
      ),
    );
  }

  Widget _stage(String name,String time){

    return Padding(
      padding: const EdgeInsets.only(bottom:6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(name),

          Text(time,style: const TextStyle(fontWeight: FontWeight.bold))

        ],
      ),
    );
  }

  Widget _tip(String text){

    return Padding(
      padding: const EdgeInsets.only(bottom:6),

      child: Row(
        children: [

          const Icon(Icons.check_circle,color:Colors.green,size:18),

          const SizedBox(width:8),

          Expanded(child: Text(text)),

        ],
      ),
    );
  }

  Widget _card({required Widget child}){

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
      ),

      child: child,
    );
  }
}

class _OverviewWaveClipper extends CustomClipper<Path>{

  @override
  Path getClip(Size size){

    final path = Path();

    path.lineTo(0,115);
    path.quadraticBezierTo(size.width*0.22,35,size.width*0.52,98);
    path.quadraticBezierTo(size.width*0.82,160,size.width,85);
    path.lineTo(size.width,size.height);
    path.lineTo(0,size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper)=>false;

}