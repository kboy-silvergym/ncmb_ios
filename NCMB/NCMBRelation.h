/*******
 Copyright 2014 NIFTY Corporation All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 **********/

#import <Foundation/Foundation.h>

@class NCMBObject;
@class NCMBQuery;

/**
 NCMBRelationは、オブジェクトの関係を管理するクラスです。
 */
@interface NCMBRelation : NSObject

@property(nonatomic) NCMBObject *parent;
@property(nonatomic) NSString *key;
@property(nonatomic) NSString *targetClass;

/**
 リレーションで示されたオブジェクトのクラス名を指定してクエリを生成
 */
- (NCMBQuery *)query;

/**
 Relation初期化用
 */
- (id)initWithClassName:(NCMBObject *)parent key:(NSString *)key;

/**
 指定されたクラス名を設定したNCMBRelationのインスタンスを返却する
 @param className リレーション先のクラス名
 */
- (id)initWithClassName:(NSString *)className;

/**
 リレーションに指定したオブジェクトを追加
 @param object 指定するオブジェクト
 */
- (void)addObject:(NCMBObject *)object;

/**
 リレーションから指定したオブジェクトを削除
 @param object 指定するオブジェクト
 */
- (void)removeObject:(NCMBObject *)object;

@end