import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tutorial_flutter/media_services.dart';

class InstagramMediaPicker extends StatefulWidget {
  const InstagramMediaPicker({super.key});

  @override
  State<InstagramMediaPicker> createState() => _InstagramMediaPickerState();
}

class _InstagramMediaPickerState extends State<InstagramMediaPicker> {
  AssetEntity? selectedEntity;
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];

  bool isMultiple = false;

  @override
  void initState() {
    MediaServices().loadAlbums(RequestType.common).then(
      (value) {
        setState(() {
          albumList = value;
          selectedAlbum = value[0];
        });
        //LOAD RECENT ASSETS
        MediaServices().loadAssets(selectedAlbum!).then(
          (value) {
            setState(() {
              selectedEntity = value[0];
              assetList = value;
            });
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          leading: const CloseButton(
            color: Colors.white,
          ),
          centerTitle: true,
          title: const Text("Instagram Media Picker"),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: height * 0.5,
              child: selectedEntity == null
                  ? const SizedBox.shrink()
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: AssetEntityImage(
                            selectedEntity!,
                            isOriginal: false,
                            thumbnailSize: const ThumbnailSize.square(1000),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                        if (selectedEntity!.type == AssetType.video)
                          const Positioned.fill(
                            child: Center(
                              child: Icon(
                                Iconsax.play_circle5,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        if (selectedAlbum != null)
                          GestureDetector(
                            onTap: () {
                              albums(height);
                            },
                            child: Text(
                              selectedAlbum!.name == "Recent"
                                  ? "Gallery"
                                  : selectedAlbum!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                          ),
                          child: Icon(
                            Iconsax.arrow_down_1,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isMultiple = isMultiple == true ? false : true;
                              selectedAssetList = [];
                            });
                          },
                          icon: Icon(
                            isMultiple == true
                                ? Iconsax.note_215
                                : Iconsax.note_2,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Iconsax.camera,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: assetList.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: assetList.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                            ),
                            itemBuilder: (context, index) {
                              AssetEntity assetEntity = assetList[index];
                              return assetWidget(assetEntity);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void albums(height) {
    showModalBottomSheet(
      backgroundColor: const Color(0xff101010),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      builder: (context) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: albumList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                setState(() {
                  selectedAlbum = albumList[index];
                });
                MediaServices().loadAssets(selectedAlbum!).then(
                  (value) {
                    setState(() {
                      assetList = value;
                      selectedEntity = assetList[0];
                    });
                  },
                );
                Navigator.pop(context);
              },
              title: Text(
                albumList[index].name == "Recent"
                    ? "Gallery"
                    : albumList[index].name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void selectAsset({
    required AssetEntity assetEntity,
  }) {
    if (selectedAssetList.contains(assetEntity)) {
      setState(() {
        selectedAssetList.remove(assetEntity);
      });
    } else {
      setState(() {
        selectedAssetList.add(assetEntity);
      });
    }
  }
  Widget assetWidget(AssetEntity assetEntity) => GestureDetector(
        onTap: () {
          setState(() {
            selectedEntity = assetEntity;
          });
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetEntityImage(
                assetEntity,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ),
            if (assetEntity.type == AssetType.video)
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Iconsax.video5,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                color: assetEntity == selectedEntity
                    ? Colors.white60
                    : Colors.transparent,
              ),
            ),
            if (isMultiple == true)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      selectAsset(assetEntity: assetEntity);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedAssetList.contains(assetEntity) == true
                              ? Colors.blue
                              : Colors.white12,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "${selectedAssetList.indexOf(assetEntity) + 1}",
                            style: TextStyle(
                              color: selectedAssetList.contains(assetEntity) ==
                                      true
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

}
