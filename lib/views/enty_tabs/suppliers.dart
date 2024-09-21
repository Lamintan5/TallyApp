import 'dart:convert';
import 'dart:io';

import 'package:TallyApp/Widget/buttons/bottom_call_buttons.dart';
import 'package:TallyApp/Widget/dialogs/call_actions/double_call_action.dart';
import 'package:TallyApp/Widget/dialogs/dialog_edit_supplier.dart';
import 'package:TallyApp/Widget/dialogs/dialog_title.dart';
import 'package:TallyApp/Widget/empty_data.dart';
import 'package:TallyApp/main.dart';
import 'package:TallyApp/models/data.dart';
import 'package:TallyApp/models/duties.dart';
import 'package:TallyApp/models/entities.dart';
import 'package:TallyApp/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/buttons/card_button.dart';
import '../../Widget/dialogs/dialog_add_supplier.dart';
import '../../Widget/dialogs/dialog_request.dart';
import '../../models/suppliers.dart';
import '../../utils/colors.dart';

class Suppliers extends StatefulWidget {
  final EntityModel entity;
  const Suppliers({super.key, required this.entity});

  @override
  State<Suppliers> createState() => _SuppliersState();
}

class _SuppliersState extends State<Suppliers> {
  final ScrollController _horizontal = ScrollController();
  TextEditingController _search = TextEditingController();
  List<SupplierModel> _supplier = [];
  List<SupplierModel> _newSupplier = [];
  List<DutiesModel> _newduties = [];
  List<String> title = ['Suppliers'];
  List<String> _dutiesList = [];
  List<DutiesModel> _duties = [];

  int count = 0;
  int removed = 0;
  bool close = true;
  List<String> admin = [];
  late bool _layout;
  bool _loading = false;
  int? sortColumnIndex;
  bool isAscending = false;
  String selectedID = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
    if(Platform.isAndroid || Platform.isIOS){
      _layout = false;
    } else {
      _layout = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _supplier.forEach((item) {
        if (item.name.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            ||item.category.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            ||item.email.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            ||item.phone.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
        )
          filteredList.add(item);
      });
    } else {
      filteredList = _supplier;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
          child: Text('Suppliers', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1
                    ),
                    itemCount: title.length,
                    itemBuilder: (context, index){
                      return Card(
                        margin: EdgeInsets.all(5),
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title[index], style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black),),
                            SizedBox(height: 10,),
                            Text(count.toString(), style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),)
                          ],
                        ),
                      );
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CardButton(
                      text: 'Add',
                      backcolor: Colors.white,
                      icon: Icon(
                        Icons.add,
                        color:  admin.contains(currentUser.uid)
                            ? screenBackgroundColor
                            : _dutiesList.contains("SUPPLIER")
                            ?screenBackgroundColor
                            :Colors.red,
                        size: 19,),
                      forecolor:  admin.contains(currentUser.uid)
                          ? screenBackgroundColor
                          : _dutiesList.contains("SUPPLIER")
                          ?screenBackgroundColor
                          :Colors.red,
                      onTap: () {
                        admin.contains(currentUser.uid)
                            ? dialogAddSupplier(context)
                            : _dutiesList.contains("SUPPLIER")
                            ?dialogAddSupplier(context)
                            :dialogRequest(context, "Add");
                      },
                    ),
                    _supplier.isEmpty
                        ? SizedBox()
                        : CardButton(
                      text: _layout?'List':'Table',
                      backcolor: Colors.white,
                      icon: Icon(_layout?CupertinoIcons.list_dash:CupertinoIcons.table, color: screenBackgroundColor,size: 16,),
                      forecolor: screenBackgroundColor,
                      onTap: () {
                        setState(() {
                          _layout=!_layout;
                        });
                      },
                    ),
                    CardButton(
                      text: _supplier.any((element) => element.checked == "false" || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE") )
                          ? "Upload"
                          :'Reload',
                      backcolor: _supplier.any((element) => element.checked == "false" || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE") )
                          ?Colors.red
                          :screenBackgroundColor,
                      icon: Icon(
                        _supplier.any((element) => element.checked == "false" || element.checked.toString().contains("EDIT") || element.checked.toString().contains("DELETE") )
                            ?Icons.cloud_upload_rounded
                            :CupertinoIcons.refresh,
                        size: 16,
                        color:Colors.white,
                      ),
                      forecolor: Colors.white, onTap: () {
                        _getDetails();
                      },
                    ),
                  ],
                ),
                close == false
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 400,
                          maxWidth: 600,
                        ),
                      child: Card(
                        color: Colors.white,
                        elevation: 8,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.delete, size: 30, color: Colors.red,),
                              SizedBox(width: 15,),
                              Expanded(
                                child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(fontSize: 13),
                                        children: [
                                          TextSpan(
                                              text: "Attention: ",
                                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: "${removed.toString()} ",
                                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: removed > 1? "suppliers have " : "supplier has ",
                                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                          ),
                                          TextSpan(
                                              text: "been removed from our server by one of the managers. This change may impact your data. Would you like to update your list to reflect these changes? ",
                                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                                          ),
                                          WidgetSpan(
                                              child: InkWell(
                                                  onTap: (){_removeAll();},
                                                  child: Text("Remove All", style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.bold),)
                                              )
                                          )
                                        ]
                                    )
                                ),
                              ),
                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      close = true;
                                    });
                                  },
                                  icon: Icon(Icons.close, size: 30,color: Colors.black,)
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    :SizedBox(),
                _supplier.isEmpty
                    ? SizedBox()
                    : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Divider(
                          height: 1,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0),
                        child: Text('Suppliers List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500 , color: Colors.black),),
                      ),
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                _supplier.isEmpty
                    ? EmptyData(
                    onTap: (){
                      admin.contains(currentUser.uid)
                          ? dialogAddSupplier(context)
                          : _dutiesList.contains("SUPPLIER")
                          ?dialogAddSupplier(context)
                          :dialogRequest(context, "Add");
                    },
                    title: "suppliers",
                    highlightColor: admin.contains(currentUser.uid)
                            ? Colors.white
                            : _dutiesList.contains("SUPPLIER")
                            ?Colors.white
                            :Colors.red,
                    )
                    : SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 300,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black
                                  ),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _search,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                      hintText: "Search...",
                                      hintStyle: TextStyle(color: secondaryColor),
                                      filled: false,
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(8),
                                      icon: Icon(Icons.search, color: Colors.black,),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none
                                      )
                                  ),
                                  onChanged:  (value) => setState((){}),
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              _loading? SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  color: screenBackgroundColor,
                                  strokeWidth: 2,
                                ),
                              ) : SizedBox()
                            ],
                          ),
                          SizedBox(height: 20,),
                          _layout
                              ? Scrollbar(
                            thumbVisibility: true,
                            controller: _horizontal,
                                child: SingleChildScrollView(
                                  controller: _horizontal,
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                headingRowHeight: 30,
                                headingRowColor: WidgetStateColor.resolveWith((states) {
                                  return screenBackgroundColor;
                                }),
                                sortColumnIndex: sortColumnIndex,
                                sortAscending: isAscending,
                                columns:  [
                                  DataColumn(
                                    label: Text("Full Name", style: TextStyle(color: Colors.white),),
                                    numeric: false,
                                    onSort: onSort,
                                    tooltip: "Click to sort suppliers based on name"
                                  ),
                                  DataColumn(
                                    label: Text("Company", style: TextStyle(color: Colors.white),),
                                    numeric: false,
                                    onSort: onSort,
                                      tooltip: "Click to sort suppliers based on company name"
                                  ),
                                  DataColumn(
                                    label: Text("Category", style: TextStyle(color: Colors.white),),
                                    numeric: false,
                                    onSort: onSort,
                                      tooltip: "Click to sort suppliers based on category"
                                  ),
                                  DataColumn(
                                    label: Text("Phone", style: TextStyle(color: Colors.white),),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Text("Email", style: TextStyle(color: Colors.white),),
                                    numeric: false,
                                  ),
                                  DataColumn(
                                    label: Text("Action", style: TextStyle(color: Colors.white),),
                                    numeric: false,
                                  ),
                                ],
                                rows: filteredList.map((supplier) => DataRow(cells: [
                                  DataCell(
                                      Text(supplier.name.toString(),style: TextStyle(color: Colors.black),),
                                      onTap: (){
                                        // _setValues(inventory);
                                        // _selectedInv = inventory;
                                      }
                                  ),
                                  DataCell(
                                      Text(supplier.company.toString(),style: TextStyle(color: Colors.black),),
                                      onTap: (){
                                        // _setValues(inventory);
                                        // _selectedInv = inventory;
                                      }
                                  ),
                                  DataCell(
                                      Text(supplier.category.toString(),style: TextStyle(color: Colors.black),),
                                      onTap: (){
                                        // _setValues(inventory);
                                        // _selectedInv = inventory;
                                      }
                                  ),
                                  DataCell(
                                      Text(supplier.phone.toString(),style: TextStyle(color: Colors.black),),
                                      onTap: (){
                                        // _setValues(inventory);
                                        // _selectedInv = inventory;
                                      }
                                  ),
                                  DataCell(
                                      Text(supplier.email.toString(),style: TextStyle(color: Colors.black),),
                                      onTap: (){
                                        // _setValues(inventory);
                                        // _selectedInv = inventory;
                                      }
                                  ),
                                  DataCell(
                                    Center(
                                        child: PopupMenuButton<String>(
                                          tooltip: 'Show options',
                                          child: Icon(
                                            supplier.checked == "false"
                                                ?Icons.cloud_upload
                                                :supplier.checked.contains("DELETE") || supplier.checked.contains("REMOVED")
                                                ?CupertinoIcons.delete
                                                :supplier.checked.contains("EDIT")
                                                ?Icons.edit_rounded
                                                :Icons.more_vert,
                                            color
                                              : supplier.checked == "false" || supplier.checked.contains("DELETE") || supplier.checked.contains("EDIT")
                                                || supplier.checked.contains("REMOVED")
                                              ? Colors.red
                                              :screenBackgroundColor,
                                          ),
                                          onSelected: (value) {
                                            print('Selected: $value');
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              if (supplier.checked == "false" || supplier.checked == "false, EDIT" || supplier.checked.toString().contains("REMOVED"))
                                                PopupMenuItem(
                                                  value: 'upload',
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.cloud_upload, color: Colors.red,),
                                                      SizedBox(width: 5,),
                                                      Text(
                                                        'Upload', style: TextStyle(
                                                        color:Colors.red,),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: (){
                                                    _upload(supplier);
                                                  },
                                                ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(CupertinoIcons.delete,
                                                      color: admin.contains(currentUser.uid)
                                                        ? reverse
                                                        : _dutiesList.contains("SUPPLIER")
                                                        ?reverse
                                                        :Colors.red,),
                                                    SizedBox(width: 5,),
                                                    Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                      color: admin.contains(currentUser.uid)
                                                          ? reverse
                                                          : _dutiesList.contains("SUPPLIER")
                                                          ?reverse
                                                          :Colors.red,
                                                    ),),
                                                  ],
                                                ),
                                                onTap: (){
                                                  supplier.checked.contains("DELETE")
                                                      ?dialogCloudDelete(context, supplier)
                                                      :dialogDelete(context, supplier);
                                                },
                                              ),

                                              PopupMenuItem(
                                                value: supplier.checked.contains("DELETE")
                                                    ?'Restore'
                                                    :'Edit',
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      supplier.checked.contains("DELETE")
                                                          ?Icons.restore
                                                          :Icons.edit,
                                                      color: admin.contains(currentUser.uid)
                                                        ? reverse
                                                        : _dutiesList.contains("SUPPLIER")
                                                        ?reverse
                                                        :Colors.red,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text(supplier.checked.contains("DELETE")? 'Restore' : 'Edit',
                                                      style: TextStyle(
                                                      color: admin.contains(currentUser.uid)
                                                          ? reverse
                                                          : _dutiesList.contains("SUPPLIER")
                                                          ?reverse
                                                          :Colors.red,),
                                                    ),
                                                  ],
                                                ),
                                                onTap: (){
                                                  supplier.checked.contains("DELETE")
                                                      ?_restore(supplier)
                                                      :dialogEdit(context, supplier);
                                                },
                                              ),

                                            ];
                                          },
                                        )
                                    ),

                                  ),

                                ]),
                                ).toList(),
                                                            ),
                                                          ),
                              )
                              : SizedBox(width: 450,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index){
                                  SupplierModel supplier = filteredList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: AnimatedContainer(
                                      duration: Duration(seconds: 2),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              setState(() {
                                                if(selectedID!=supplier.sid){
                                                  selectedID = supplier.sid;
                                                } else {
                                                  selectedID = "";
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: Colors.black12,
                                                  child: Center(
                                                      child:
                                                      supplier.checked == "false"
                                                          ?Icon(Icons.cloud_upload, color: Colors.red,)
                                                          :supplier.checked.toString().contains("DELETE") || supplier.checked.toString().contains("REMOVED")
                                                          ?Icon(CupertinoIcons.delete, color: Colors.red,)
                                                          :supplier.checked.toString().contains("EDIT")
                                                          ?Icon(Icons.edit_rounded, color: Colors.red)
                                                          :LineIcon.user(color: Colors.black,),
                                                  ),
                                                ),
                                                SizedBox(width: 10,),
                                                Expanded(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(supplier.name.toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                                              Text('${supplier.company},  ${supplier.category}', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),),
                                                            ],
                                                          ),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Text('${supplier.phone}', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w400, fontSize: 11),),
                                                            Text('${supplier.email}', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w400, fontSize: 11),),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                          index == filteredList.length - 1 && selectedID != supplier.sid && filteredList.length != 0
                                              ?SizedBox()
                                              :Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5),
                                            child: Divider(
                                              color: Colors.black12,
                                              thickness: 1,height: 1,
                                            ),
                                          ),
                                          AnimatedSize(
                                              duration: Duration(milliseconds: 500),
                                              alignment: Alignment.topCenter,
                                              curve: Curves.easeInOut,
                                            child: selectedID == supplier.sid
                                                ? IntrinsicHeight(
                                              child: Row(
                                                children: [
                                                  supplier.checked == "false" || supplier.checked == "false, EDIT" || supplier.checked.toString().contains("REMOVED")? BottomCallButtons(
                                                      onTap: (){ _upload(supplier);},
                                                      icon: Icon(Icons.cloud_upload, color: Colors.black,),
                                                      actionColor: Colors.black,
                                                      backColor: Colors.red.withOpacity(0.9),
                                                      title: "Upload"
                                                  ) : SizedBox(),
                                                  supplier.checked == "false" || supplier.checked == "false, EDIT" || supplier.checked.toString().contains("REMOVED")?VerticalDivider(
                                                    thickness: 0.5,
                                                    width: 15,color: Colors.black12,
                                                  ) : SizedBox(),
                                                  BottomCallButtons(
                                                      onTap: (){
                                                        supplier.checked.toString().contains("DELETE")
                                                            ?dialogCloudDelete(context, supplier)
                                                            :dialogDelete(context, supplier);
                                                      },
                                                      icon: Icon(CupertinoIcons.delete, color: Colors.black,),
                                                      actionColor: Colors.black,
                                                      title: "Delete"
                                                  ),
                                                  VerticalDivider(
                                                    thickness: 0.5,
                                                    width: 15,color: Colors.black12,
                                                  ),
                                                  BottomCallButtons(
                                                      onTap: (){
                                                        supplier.checked.toString().contains("DELETE")
                                                            ?_restore(supplier)
                                                            : dialogEdit(context, supplier);
                                                      },
                                                      icon: Icon(
                                                        supplier.checked.toString().contains("DELETE")?Icons.restore:Icons.edit,
                                                        color: Colors.black,),
                                                      actionColor: Colors.black,
                                                      title: supplier.checked.toString().contains("DELETE")
                                                          ? 'Restore'
                                                          :"Edit"
                                                  ),
                                                ],
                                              ),
                                            )
                                                : SizedBox(),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                 
              ],
            ),
          ),
        )
      ],
    );
  }
  void dialogRequest(BuildContext, String action){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final secBtn = Theme.of(context).brightness == Brightness.dark
        ? Colors.cyanAccent
        : Colors.cyan;
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E Q U E S T'),
                DialogRequest(action: action, account: 'SUPPLIER', entity: widget.entity,),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogAddSupplier(BuildContext context) {
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'A D D  S U P P L I E R'),
                Text('Enter details based on your items inorder to promote better user experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DialogAddSupplier(
                  entity: widget.entity,
                  addSupplier: _addSupplier,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogDelete(BuildContext context, SupplierModel supplier){
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E M O V E'),
                Text(
                  'Are you sure you wish to proceed? This action will permanently affect any record associated with this data',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DoubleCallAction(action: (){
                  Navigator.pop(context);
                  _delete(supplier);
                  }, title: "Delete",titleColor: Colors.red,)
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogCloudDelete(BuildContext context, SupplierModel supplier){
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E M O V E'),
                Text(
                  'Please confirm if you wish to proceed with the deletion of the supplier ${supplier.name} from the server.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DoubleCallAction(action: (){
                  Navigator.pop(context);
                  _delete(supplier);
                  }, title: "Delete",titleColor: Colors.red,)
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogEdit(BuildContext context, SupplierModel supplier){
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'E D I T'),
                Text('enter the new details for ${supplier.name} inorder to keep update your data',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                DialogEditSupplier(supplier: supplier, getData: _reload,)
              ],
            ),
          ),
        ),
      );
    });
  }

  _updateSupplier(SupplierModel supplier)async{
    print("Update Supplier ");
    _supplier.firstWhere((element) => element.sid == supplier.sid).checked = "true";
    await Data().addOrUpdateSuppliersList(_supplier);
    setState(() {
    });
  }
  _addSupplier(SupplierModel supplier)async{
    List<String> uniqueSuppliers= [];
    List<SupplierModel> _mysupplier = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _mysupplier = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _mysupplier.add(supplier);
    _supplier.add(supplier);

    uniqueSuppliers = _mysupplier.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mysuppliers', uniqueSuppliers);
    mySuppliers = uniqueSuppliers;
    _getData();

    count = _supplier.length;
    await Services.addSupplier(supplier).then((response){
      if(response == "Success"){
        supplier.checked = "true";
        _mysupplier.firstWhere((element) => element.sid == supplier.sid).checked = "true";
        uniqueSuppliers = _mysupplier.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mysuppliers', uniqueSuppliers);
        mySuppliers = uniqueSuppliers;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Supplier ${supplier.name} was added to Suppliers list Succesfully"),
          showCloseIcon: true,
        ));
        _getData();
      }
    });
  }

  _getDetails()async{
    _getData();
    await Data().checkSuppliers(_supplier, (){});
    _newSupplier = await Services().getMySuppliers(currentUser.uid);
    _newduties = await Services().getMyDuties(currentUser.uid);
    await Data().addOrUpdateSuppliersList(_newSupplier);
    await Data().addOrUpdateDutyList(_newduties);
    _getData();
  }
  _getData() async {
    _supplier = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _supplier = _supplier.where((element) => element.eid == widget.entity.eid).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _duties = _duties.where((element) => element.eid == widget.entity.eid).toList();
    admin = widget.entity.admin!.split(",");
    count = _supplier.length;
    _dutiesList = _duties.isEmpty ? [] : _duties.first.duties!.split(",");
    removed = _supplier.where((element) => element.checked == "REMOVED").length;
    close = removed > 0? false: true;
    setState(() {
      _loading = false;
    });
  }

  _reload()async{
    _supplier = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _supplier = _supplier.where((element) => element.eid == widget.entity.eid).toList();
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    _duties = _duties.where((element) => element.eid == widget.entity.eid).toList();
    admin = widget.entity.pid!.split(",");
    count = _supplier.length;
    _dutiesList = _duties.isEmpty? [] : _duties.first.duties!.split(",");
    // for (var supplier in _supplier) {
    //   await Data().checkAndUploadSupplier(supplier, _updateSupplier);
    // }

    setState(() {
      _loading = false;
    });
  }
  _upload(SupplierModel supplier)async{
    List<String> uniqueSuppliers= [];
    List<SupplierModel> _mysupplier = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _mysupplier = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    setState(() {
      _loading = true;
    });
    Services.addSupplier(supplier).then((response){
      if (response == "Success")
      {
        _supplier.firstWhere((element) => element.sid == supplier.sid).checked = "true";
        _mysupplier.firstWhere((element) => element.sid == supplier.sid).checked = "true";
        uniqueSuppliers = _mysupplier.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mysuppliers', uniqueSuppliers);
        mySuppliers = uniqueSuppliers;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Supplier ${supplier.name} was uploaded Successfully"),
              showCloseIcon: true,
            )
        );
      } else if (response == "Failed")
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Supplier ${supplier.name} was not uploaded. Please try again"),
              showCloseIcon: true,
              action: SnackBarAction(label: "Try Again", onPressed: _upload(supplier)),
            )
        );
      } else if(response == 'Exists')
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Supplier ${supplier.name} already Exists"),
              showCloseIcon: true,
            )
        );
      } else
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("mhmm 🤔 seems like something went wrong. Please try again later"),
              showCloseIcon: true,
            )
        );
      }
      setState(() {
        _loading = false;
      });
    });
  }
  _delete(SupplierModel supplier)async{
    setState(() {
      _loading = true;
    });
    await Data().removeSupplier(supplier, _getData, context).then((value){
      setState(() {
        _loading = value;
      });
    });
  }
  _restore(SupplierModel supplier)async{
    List<String> uniqueSupplier = [];
    List<SupplierModel> _spplr = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _spplr.firstWhere((element) => element.sid == supplier.sid).checked = supplier.checked.toString().replaceAll(", DELETE", "");;
    uniqueSupplier = _spplr.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
    mySuppliers = uniqueSupplier;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Supplier ${supplier.name} restored Successfully")
        )
    );
    _getData();
  }

  _removeAll()async{
    List<String> uniqueSupplier = [];
    List<SupplierModel> _spplr = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _spplr = mySuppliers.map((jsonString) => SupplierModel.fromJson(json.decode(jsonString))).toList();
    _spplr.removeWhere((element) => element.checked == "REMOVED" && element.eid == widget.entity.eid);
    _supplier.removeWhere((element) => element.checked == "REMOVED");
    uniqueSupplier = _spplr.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList("mysuppliers", uniqueSupplier);
    mySuppliers = uniqueSupplier;
    _getData();
    close = removed > 0? false: true;
    setState(() {

    });
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
    ),
  );
  void onSort(int columnIndex, bool ascending){
    if(columnIndex == 0){
      _supplier.sort((supp1, supp2) =>
          compareString(ascending, supp1.name.toString(), supp2.name.toString())
      );
    } else if (columnIndex == 1){
      _supplier.sort((supp1, supp2) =>
          compareString(ascending, supp1.company.toString(), supp2.company.toString())
      );
    }else if (columnIndex == 2){
      _supplier.sort((supp1, supp2) =>
          compareString(ascending, supp1.category.toString(), supp2.category.toString())
      );
    }
    setState(() {
      this.sortColumnIndex = columnIndex;
      this.isAscending = ascending;
    });
  }
  int compareString(bool ascending, String value1, String value2){
    return ascending? value1.compareTo(value2) : value2.compareTo(value1);
  }
}
