<template>
  <a-layout>
    <a-layout-content
        :style="{ background: '#fff', padding: '24px', margin: 0, minHeight: '280px' }"
    >
      <p>
        <a-form layout="inline" :model="param">
          <a-form-item>
            <a-button type="primary" @click="handleQuery()">
              查询
            </a-button>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="add()">
              新增
            </a-button>
          </a-form-item>
        </a-form>
      </p>
      <a-table
          :columns="columns"
          :row-key="record => record.id"
          :data-source="level1"
          :pagination="false"
          :loading="loading"
      >
        <template #cover="{ text: cover }">
          <img v-if="cover" :src="cover" alt="avatar"/>
        </template>
        <template v-slot:action="{ text, record }">
          <a-space size="small">
            <a-button type="primary" @click="edit(record)">
              编辑
            </a-button>
            <a-popconfirm
                title="删除后不可恢复，确认删除？"
                ok-text="是"
                cancel-text="否"
                @confirm="handleDelete(record.id)"
            >
              <a-button danger>删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </a-table>
      <div class="about">
        <h1>文档管理</h1>
      </div>
    </a-layout-content>
  </a-layout>
  <a-modal
      title="文档表单"
      v-model:visible="modalVisible"
      :confirm-loading="modalLoading"
      @ok="handleModalOk"
  >
    <a-form :model="doc" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
      <a-form-item label="名称">
        <a-input v-model:value="doc.name"/>
      </a-form-item>

      <a-form-item label="父文档">
        <!--这里的doc.parent都是0，因为选择的是一级文档-->
        <a-select
            ref="select"
            v-model:value="doc.parent"
        >
          <a-select-option value="0">无</a-select-option>
          <!--level1就是父级文档，不包含子集的，，key就是和表结构对应的，有id，有name 。value也是
          和key是一样的。如果你选的父级文档是自己的id，那就不能选了。这个是在编辑的时候
          ，因为编辑的时候，你的id就带过来了，是一级文档，这里也是一级文档，所以不能选-->
          <a-select-option v-for="c in level1" :key="c.id" :value="c.id" :disabled="doc.id === c.id">
            {{ c.name }}
          </a-select-option>
        </a-select>
      </a-form-item>

      <a-form-item label="顺序">
        <a-input v-model:value="doc.sort"/>
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<script lang="ts">
import {defineComponent, onMounted, ref} from 'vue';
import axios from 'axios';
import {message} from 'ant-design-vue';
import {Tool} from "@/util/tool";

export default defineComponent({
  name: 'AdminDoc',
  setup() {
    const param = ref();
    param.value = {};
    const docs = ref();
    const loading = ref(false);

    const columns = [
      {
        title: '名称',
        dataIndex: 'name'
      },
      {
        title: '父文档',
        key: 'parent',
        dataIndex: 'parent'
      },
      {
        title: '顺序',
        dataIndex: 'sort'
      },
      {
        title: 'Action',
        key: 'action',
        slots: {customRender: 'action'}
      }
    ];

    /**
     * 一级文档树，children属性就是二级文档
     * [{
     *   id: "",
     *   name: "",
     *   children: [{
     *     id: "",
     *     name: "",
     *   }]
     * }]
     */
    const level1 = ref(); // 一级文档树，children属性就是二级文档
    level1.value = [];

    /**
     * 数据查询
     **/
    const handleQuery = () => {
      loading.value = true;
      // 如果不清空现有数据，则编辑保存重新加载数据后，再点编辑，则列表显示的还是编辑前的数据
      axios.get("/doc/all").then((response) => {
        loading.value = false;
        //response.data是固定的，这个组件内置的，就是后端返回回来的全部
        const data = response.data;
        if (data.success) {
          //这个content就是之前的data，这里的content就是CommonResponse里面的。
          docs.value = data.content;
          console.log("原始数组" + docs.value);
          level1.value = [];
          level1.value = Tool.array2Tree(docs.value, 0);
          console.log("树形结构：", level1);
        } else {
          message.error(data.message);
        }
      });
    };


    //---------------表单------------
    const doc = ref({});
    const modalVisible = ref(false);
    const modalLoading = ref(false);
    const handleModalOk = () => {
      modalLoading.value = true;
      axios.post("/doc/save", doc.value).then((response) => {
        modalLoading.value = false;
        const data = response.data;//data = commonResponse
        if (data.success) {
          modalVisible.value = false;
          //重新加载列表
          handleQuery();
        } else {
          message.error(data.message);
        }
      });
    }
    /**
     * 编辑
     */
    const edit = (record: any) => {
      modalVisible.value = true;
      doc.value = Tool.copy(record);
    }

    /**
     * 新增
     */
    const add = () => {
      modalVisible.value = true;
      doc.value = {};
    }
    /**
     * 删除
     */
    const handleDelete = (id: number) => {
      axios.delete("/doc/delete/" + id).then((response) => {

        const data = response.data;//data = commonResponse
        if (data.success) {
          //重新加载列表

          handleQuery();
        }
      });
    };

    onMounted(() => {
      handleQuery();
    });

    return {
      level1,
      param,
      // docs,
      columns,
      loading,
      handleQuery,

      edit,
      add,

      doc,
      modalVisible,
      modalLoading,
      handleModalOk,
      handleDelete
    }
  }
});
</script>

<style scoped>
img {

  width: 50px;
  height: 50px;
}
</style>
