---
title: Springboot连接阿里云ES实现文档搜索
categories: Elasticsearch
tags:
  - Elasticsearch
  - 阿里云生态
top: 60
abbrlink: 2994242534
date: 2021-09-28 11:04:45
password:
---

# 引言

对于某些项目可能会涉及到大量的数据，而这些数据又需要经常搜索，那么如果从数据库中查询则效率会比较低，而且不够智能化，那么我们可以使用Elasticsearch来实现文档搜索，而阿里云的ES则是一个很好的选择。

<!--more-->

# 基础

- 首先需要在Springboot工程中引入连接阿里云ES所需的jar包，这里我用的是6.7.0的版本。

```java

<dependency>
    <groupId>org.elasticsearch.client</groupId>
    <artifactId>elasticsearch-rest-high-level-client</artifactId>
    <version>6.7.0</version>
</dependency>

```

- 在application.yml配置ES相关的属性。

```java
spring:
  elasticsearch:
    username: xxxxxxx
    password: xxxxxx
    cluster_host: xxxxxxxxxxxx
    cluster_port: 9200
```

# 使用

## 编写连接阿里云ES的工具类


```java
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.nio.client.HttpAsyncClientBuilder;
import org.elasticsearch.action.bulk.BulkRequest;
import org.elasticsearch.action.bulk.BulkResponse;
import org.elasticsearch.action.delete.DeleteRequest;
import org.elasticsearch.action.delete.DeleteResponse;
import org.elasticsearch.action.get.GetRequest;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;

import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.update.UpdateRequest;
import org.elasticsearch.action.update.UpdateResponse;
import org.elasticsearch.client.HttpAsyncResponseConsumerFactory;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestClientBuilder;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.client.core.CountRequest;
import org.elasticsearch.client.core.CountResponse;
import org.elasticsearch.client.indices.CreateIndexRequest;
import org.elasticsearch.client.indices.CreateIndexResponse;
import org.elasticsearch.client.indices.GetIndexRequest;
import org.elasticsearch.common.text.Text;
import org.elasticsearch.common.unit.TimeValue;
import org.elasticsearch.common.xcontent.XContentType;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.Operator;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.index.reindex.DeleteByQueryRequest;
import org.elasticsearch.rest.RestStatus;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.fetch.subphase.FetchSourceContext;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.elasticsearch.search.sort.SortBuilders;
import org.elasticsearch.search.sort.SortOrder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;

import com.alibaba.fastjson.JSON;

import com.suntree.commons.ApiResult;
import com.suntree.commons.Page;
import com.suntree.entity.EsDocument;

import lombok.extern.log4j.Log4j2;

@Component
@Log4j2
public class ElasticsearchUtil {
	private static final RequestOptions COMMON_OPTIONS;
	
	@Value("${spring.elasticsearch.cluster_host}")
	private String cluster_host;
	@Value("${spring.elasticsearch.cluster_port}")
	private Integer cluster_port;
	@Value("${spring.elasticsearch.username}")
	private String username;
	@Value("${spring.elasticsearch.password}")
	private String password;
    static {
        RequestOptions.Builder builder = RequestOptions.DEFAULT.toBuilder();

        // 默认缓存限制为100MB，此处修改为30MB。
        builder.setHttpAsyncResponseConsumerFactory(
                new HttpAsyncResponseConsumerFactory
                        .HeapBufferedResponseConsumerFactory(30 * 1024 * 1024));
        COMMON_OPTIONS = builder.build();
    }
    public RestHighLevelClient getEsClient() {
    	// 阿里云Elasticsearch集群需要basic auth验证。
    	final CredentialsProvider credentialsProvider = new BasicCredentialsProvider();
    	//访问用户名和密码,创建阿里云Elasticsearch实例时设置的用户名和密码，也是Kibana控制台的登录用户名和密码。
    	credentialsProvider.setCredentials(AuthScope.ANY, new UsernamePasswordCredentials(this.username, this.password));
    	// 通过builder创建rest client，配置http client的HttpClientConfigCallback。
    	// 单击所创建的Elasticsearch实例ID，在基本信息页面获取公网地址，即为ES集群地址。
    	RestClientBuilder builder = RestClient.builder(new HttpHost(this.cluster_host, this.cluster_port))
    			.setHttpClientConfigCallback(new RestClientBuilder.HttpClientConfigCallback() {
    				@Override
    				public HttpAsyncClientBuilder customizeHttpClient(HttpAsyncClientBuilder httpClientBuilder) {
    					return httpClientBuilder.setDefaultCredentialsProvider(credentialsProvider);
    				}
    			});
    	// RestHighLevelClient实例通过REST low-level client builder进行构造。
    	RestHighLevelClient highClient = new RestHighLevelClient(builder);
    	return highClient;
    }
}
```

## 索引创建
 
```java
    
/**
 * 创建索引
 * @param index
 * @throws IOException
 */
public void createIndex(String index) throws IOException {
	if(!existsIndex(index)) {
		CreateIndexRequest request = new CreateIndexRequest(index);
        CreateIndexResponse createIndexResponse = getEsClient().indices().create(request, COMMON_OPTIONS);
        System.out.println("createIndex: " + JSON.toJSONString(createIndexResponse));
	}       
}
/**
 * 判断索引是否存在
 * @param index
 * @return
 * @throws IOException
 */
public boolean existsIndex(String index) throws IOException {
	GetIndexRequest request = new GetIndexRequest(index);
	boolean exists = getEsClient().indices().exists(request, COMMON_OPTIONS);
	System.out.println("existsIndex: " + exists);
	return exists;
}
    
```

##  记录

```java
/**
 * 判断记录是否存在
 * @param index
 * @param type
 * @param tests
 * @return
 * @throws IOException
 */
public boolean exists(String index, String type, EsDocument document) throws IOException {
	GetRequest getRequest = new GetRequest(index, type, document.getCourseID());
	getRequest.fetchSourceContext(new FetchSourceContext(false));
	getRequest.storedFields("_none_");
	boolean exists = getEsClient().exists(getRequest, COMMON_OPTIONS);
	System.out.println("exists: " + exists);
	return exists;
}

```

##  数据处理

### 添加数据

```java
/**
 * 添加数据
 *
 * @param content 数据内容
 * @param index   索引
 * @param id      id
 */
public String addData(EsDocument document, String index, String id) {
    String Id = null;
    try {
    	//index_name为索引名称；type_name为类型名称,7.0及以上版本必须为_doc；doc_id为文档的id。
    	// 同步执行，并使用自定义RequestOptions（COMMON_OPTIONS）。
    	RestHighLevelClient highClient=getEsClient();
        IndexRequest request = new IndexRequest(index,"_doc").id(id).source(JSON.toJSONString(document), XContentType.JSON);
        IndexResponse response = highClient.index(request, COMMON_OPTIONS);
        Id = response.getId();
        highClient.close();
        log.info("索引:{},数据添加,返回码:{},id:{}", index, response.status().getStatus(), Id);
    } catch (IOException e) {
        log.error("添加数据失败,index:{},id:{}", index, id);
    }
    return Id;
}
```

### 修改数据

```java

/**
 * 修改数据
 * @param content 修改内容
 * @param index   索引
 * @param id      id
 */
public String updateData(EsDocument document, String index, String id) {
	String Id = null;
	try {
		RestHighLevelClient highClient=getEsClient();
		UpdateRequest request = new UpdateRequest(index, "_doc",id).doc(JSON.toJSONString(document), XContentType.JSON);
		UpdateResponse response = highClient.update(request, COMMON_OPTIONS);
		Id = response.getId();
		highClient.close();
		log.info("数据更新,返回码:{},id:{}", response.status().getStatus(), Id);
	} catch (IOException e) {
		log.error("数据更新失败,index:{},id:{}", index, id);
	}
	return Id;
}
    
```

### 批量插入数据

```java

/**
 * 批量插入数据
 * @param index 索引
 * @param list  批量增加的数据
 */
public ApiResult insertBatch(String index,List<EsDocument> list) {
	ApiResult result=new ApiResult();
    String state = null;
    BulkRequest request = new BulkRequest();
    list.forEach(item -> request.add(new IndexRequest(index,"_doc")
            .id(item.getCourseID()).source(JSON.toJSONString(item), XContentType.JSON)));
    try {
    	RestHighLevelClient highClient=getEsClient();
        BulkResponse bulk = highClient.bulk(request, COMMON_OPTIONS);
        int status = bulk.status().getStatus();
        state = Integer.toString(status);
        highClient.close();
        log.info("索引:{},批量插入{}条数据成功!", index, list.size());
    } catch (IOException e) {
    	log.error(e.getMessage());
    	
        log.error("索引:{},批量插入数据失败", index);
        return result.failed("插入失败");
    }
    return result.success(null,"插入成功");
}

```

### ID删除数据

```java
/**
 * 根据id删除数据
 *	
 * @param index 索引
 * @param id    id
 */
public ApiResult deleteById(String index, String id) {
	ApiResult result=new ApiResult();
	String state = null;
	DeleteRequest request = new DeleteRequest(index,"_doc",id);
	try {
		DeleteResponse response = getEsClient().delete(request, COMMON_OPTIONS);
		int status = response.status().getStatus();
		state = Integer.toString(status);
		log.info("索引:{},根据id{}删除数据:{}", index, id, JSON.toJSONString(response));
	} catch (Exception e) {
		log.error("根据id删除数据失败,index:{},id:{}", index, id);
		return result.failed("删除失败");
	}
	return result.success(null,"删除成功");
}
    
```

### 条件删除数据


```java
/**
 * 根据条件删除数据
 *
 * @param index   索引
 * @param builder 删除条件
 */
public void deleteByQuery(String index, QueryBuilder builder) {
	DeleteByQueryRequest request = new DeleteByQueryRequest(index);
	request.setQuery(builder);
	//设置此次删除的最大条数
	request.setBatchSize(1000);
	try {
		getEsClient().deleteByQuery(request, COMMON_OPTIONS);
	} catch (Exception e) {
		log.error("根据条件删除数据失败,index:{}", index);
	}
}

```

### 条件查询数据

```java
/**
 * 根据条件查询数据
 *
 * @param index         索引
 * @param startPage     开始页
 * @param pageSize      每页条数
 * @param sourceBuilder 查询返回条件
 * @param queryBuilder  查询条件
 */
public Page<Map<String, Object>> searchDataPage(String index, int startPage, int pageSize,String companyId,String content,String... fieldNames) {
	SearchRequest request = new SearchRequest(index);
	request.types("_doc");
	SearchSourceBuilder sourceBuilder = new SearchSourceBuilder();
	QueryBuilder queryBuilder=createQueryBuilder(content, companyId, fieldNames);
	try {
		//加载查询条件
		sourceBuilder.query(queryBuilder);
		RestHighLevelClient highClient=getEsClient();

		long totalHits=searchDataPageCount(index, sourceBuilder, highClient);
		HighlightBuilder highlightBuilder=createHighlightBuilder(fieldNames);
		if (!ObjectUtils.isEmpty(highlightBuilder)){
			sourceBuilder.highlighter(highlightBuilder);
		}
		//设置超时时间
		sourceBuilder.timeout(new TimeValue(30, TimeUnit.SECONDS));
		//设置是否按匹配度排序
		sourceBuilder.explain(true);
		sourceBuilder.sort(SortBuilders.scoreSort().order(SortOrder.DESC));
		

		request.source(sourceBuilder);
		
		//设置分页
		sourceBuilder.from((startPage - 1) * pageSize).size(pageSize);

		log.info("查询返回条件：" + sourceBuilder.toString());
		SearchResponse searchResponse = highClient.search(request, COMMON_OPTIONS);
		//Long totalHits = searchResponse.getHits().toXContent(builder, params);
		log.info("共查出{}条记录", totalHits);
		RestStatus status = searchResponse.status();
		if (status.getStatus() == 200) {
			List<Map<String, Object>> sourceList = new ArrayList<>();
			for (SearchHit searchHit : searchResponse.getHits().getHits()) {
				Map<String,Object> map=new HashMap<>();
				Map<String, Object> sourceAsMap = searchHit.getSourceAsMap();
				map.put("source",sourceAsMap);
				// 处理高亮数据
				Map<String,Object> hitMap = new HashMap<>();
				searchHit.getHighlightFields().forEach((k,v) -> {
					String hight = "";
					for(Text text : v.getFragments()) hight += text.string();
					hitMap.put(v.getName(),hight);
				});
				map.put("highlight",hitMap);
				sourceList.add(map);
			}
			Page<Map<String, Object>> page = new Page<Map<String, Object>>();
			page.setPageNo(startPage);
			page.setPageSize(pageSize);
			page.setTotal((int)totalHits);
			page.setRows(sourceList);
			return page;
		}
		highClient.close();
	} catch (IOException e) {
		System.err.println(e.getMessage());
		log.error("条件查询索引{}时出错", index);
	}
	return null;
}
public long searchDataPageCount(String index,SearchSourceBuilder sourceBuilder,RestHighLevelClient highClient) {
	 CountRequest countRequest=new CountRequest(index);
     countRequest.source(sourceBuilder);
     try {
         CountResponse response=highClient.count(countRequest,COMMON_OPTIONS);
         long length = response.getCount();
         return length;
     } catch (IOException e) {
         e.printStackTrace();
     }
     return 0;
}
public ApiResult originSearch(String name,int pageNo,int pageSize,String indexName) {
	ApiResult result=new ApiResult();
	
	String[] fieldNames=new String[] {"title"};
	Page<Map<String, Object>> page=searchDataPage(indexName,pageNo, pageSize,"0", name,fieldNames);
	return result.success(page);
}

```

### 多字段模糊查询-高亮字段

```java
/**
 * 构建高亮字段 进行 多字段模糊查询
 */
private QueryBuilder createQueryBuilder(String content,String companyId,String ... fieldNames) {
    BoolQueryBuilder boolQueryBuilder = QueryBuilders.boolQuery();
    //自定义条件(Operator.AND 表示匹配包含值)  
    boolQueryBuilder.must(QueryBuilders.multiMatchQuery(content, fieldNames).operator(Operator.OR).minimumShouldMatch("50%"));
    boolQueryBuilder.must(QueryBuilders.boolQuery().should(QueryBuilders.termQuery("companyId", companyId)).should(QueryBuilders.termQuery("sysCourse", "1")));
    return boolQueryBuilder;
}
/**
 * 构造高亮器
 * @auther: guangz
 * @date: 2019/8/26 10:42
 */
private HighlightBuilder createHighlightBuilder(String... fieldNames){
	// 设置高亮,使用默认的highlighter高亮器
	HighlightBuilder highlightBuilder = new HighlightBuilder()
			// .field("productName")
			.preTags("<span style='color:red'>")
			.postTags("</span>");

	// 设置高亮字段
	for (String fieldName: fieldNames) {
		highlightBuilder.field(fieldName);
	}
	return highlightBuilder;
}
/*
QueryBuilders.termQuery("key", obj) 完全匹配
QueryBuilders.termsQuery("key", obj1, obj2..)   一次匹配多个值
QueryBuilders.matchQuery("key", Obj) 单个匹配, field不支持通配符, 前缀具高级特性
QueryBuilders.multiMatchQuery("text", "field1", "field2"..);  匹配多个字段, field有通配符忒行
QueryBuilders.matchAllQuery();         匹配所有文件
*/
}
```

## 相关实体类

```java
import lombok.Data;

@Data
public class EsDocument {
	//@Id
	private String courseID;
	
	private String title;
	
	private String companyId;

	private String isTop;
	
	private String isLock;
	
	private String creTm;
	
	private Integer createrID;
	
	private String createrName;
		
	//private String courseContent;//教程内容
	
	private String courseDesc;
	
	private String sysCourse;
	
	private Integer hits;//浏览量
}
```

# controller层进行相关调用测试

```java

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.suntree.commons.ApiResult;
import com.suntree.entity.CmpCourse;
import com.suntree.entity.EsDocument;
import com.suntree.mapper.CourseMapper;
import com.suntree.utils.ElasticsearchUtil;

@Controller
@RequestMapping("/search")
public class ESController {
	@Autowired
	ElasticsearchUtil es;
	@Autowired
	CourseMapper courseMapper;
	/**
	 * 高亮搜索
	 * @param name
	 * @param pageNo
	 * @param pageSize
	 * @param indexName
	 * @return
	 */
	@ResponseBody
    @GetMapping("/originSearch")
  	public ApiResult originSearch(String name,int pageNo,int pageSize,String indexName) {
  		return es.originSearch(name,pageNo,pageSize,indexName);
  	}
	/**
	 * 批量添加数据
	 * @param index
	 * @return
	 */
	@ResponseBody
    @GetMapping("/insert/{index}")
	public ApiResult insertBatch(@PathVariable("index")String index) {
		List<CmpCourse> courseList=courseMapper.selectList(null);
		List<EsDocument> lists=new ArrayList<EsDocument>();
		for(CmpCourse course : courseList) {
			EsDocument doc=new EsDocument();
			BeanUtils.copyProperties(course, doc);
			lists.add(doc);
		}
		return es.insertBatch(index,lists);
	}
}
```