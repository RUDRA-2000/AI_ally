import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mentor_ai/features.dart';
import 'package:mentor_ai/pallete.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'openAIservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText=SpeechToText();
  final fluttertts=FlutterTts();
  String lastWords='';
  final OpenAIService openAIService=OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int strt=200;
  int delay=200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void>initTextToSpeech()async{
    await fluttertts.setSharedInstance(true);
    setState(() {});
  }

  Future<void>initSpeechToText()async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    print('startlistening');
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    print(lastWords);
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content)async {
    await fluttertts.speak(content);
  }

  @override
  void dispose(){
    super.dispose();
    speechToText.stop();
    fluttertts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('AI ALLY')),
        leading:const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/virtualAssistant.png',
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
            //chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(25).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding:  const EdgeInsets.symmetric(vertical: 10.0),
                    child:  Text(
                      generatedContent == null
                          ? 'Good Morning, How can I help you?'
                          :generatedContent!,
                      style: TextStyle(
                      color: Pallete.mainFontColor,
                        fontFamily: 'Cera Pro',
                        fontSize: generatedContent==null?25:18,

                    ),),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent==null && generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10,left: 22),
                  child: const Text(
                    'Try speaking, something like...',
                    style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
              ),
            ),
            //features list
            Visibility(
              visible: generatedContent==null && generatedImageUrl==null,
              child: Column(
                children: [
                SlideInLeft(
                delay:  Duration(milliseconds: strt),
                  child:const FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText: 'The smarter way to stay organised and informed with ChatGPT',
                  ),
                ),
                  SlideInLeft(
                    delay:  Duration(milliseconds: strt + delay),
                    child:const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText: 'The smarter way to stay organised and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay:  Duration(milliseconds: strt + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText: 'The smarter way to stay organised and informed with ChatGPT',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay:  Duration(milliseconds: strt + 3 * delay),
        child: FloatingActionButton(
          onPressed: ()async {
            print('before going into listening');
            if(await speechToText.hasPermission && speechToText.isNotListening){
              await startListening();
              print('started listening');
            }
            else if(speechToText.isListening){
              final speech=await openAIService.isArtPromptAPI(lastWords);
              if(speech.contains('https')){
                generatedImageUrl=speech;
                generatedContent=null;
                setState(() {});
              }else{
                generatedImageUrl=null;
                generatedContent=speech;
                print('**debugging text $generatedContent');
                setState(() {});
                print('after setstate');
                await systemSpeak(speech);
                print('after systemspeak function');
              }
              await stopListening();
            }
            else {
              initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}
