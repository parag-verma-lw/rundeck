<template>
  <div>
    <div class="row">
      <div class="col-xs-12 col-sm-3">
        <h2 style="margin: 0px;font-size: 2.3em;margin-top: 5px;">Installed Plugins</h2>
      </div>
      <div class="col-xs-12 col-sm-3">
        <select
          class="form-control"
          @change="changeServiceFacet"
          style="height:46px"
          :disabled="view === 'detail'"
        >
          <option value>View All</option>
          <option
            v-for="(service, index) in services"
            :key="index"
            :value="service.name"
          >{{service.value}}</option>
        </select>
      </div>
      <div class="col-xs-12 col-sm-3">
        <form @submit.prevent="search">
          <div class="input-group input-group-lg">
            <input
              type="text"
              class="form-control"
              placeholder="Search for..."
              :disabled="view === 'detail'"
              v-model="searchString"
            >
            <span class="input-group-btn" v-if="searchResults.length > 0">
              <button @click="clearSearch" class="btn btn-default btn-fill" type="button">
                <i class="fas fa-times"></i>
              </button>
            </span>
            <span class="input-group-btn" v-else>
              <button
                :disabled="view === 'detail'"
                @click="search"
                class="btn btn-default btn-fill"
                type="button"
              >
                <i class="fas fa-search"></i>
              </button>
            </span>
          </div>
        </form>
      </div>
      <div class="col-xs-12 col-sm-3 text-right">
        <div class="btn-group btn-group-lg squareish-buttons" role="group">
          <button
            type="button"
            @click="view = 'grid'"
            class="btn btn-default"
            :class="{'active': view === 'grid'}"
          >Grid</button>
          <button
            type="button"
            @click="view = 'list'"
            class="btn btn-default"
            :class="{'active': view === 'list'}"
          >List</button>
          <button
            type="button"
            @click="view = 'detail'"
            class="btn btn-default"
            :class="{'active': view === 'detail'}"
          >Detail</button>
        </div>
      </div>
    </div>
    <div class="row">
      <div class="col-xs-12">
        <div v-if="searchResults.length" class="artifact-grid row row-flex row-flex-wrap">
          <ProviderCard
            v-show="view === 'grid'"
            :provider="plugin"
            class="artifact col-xs-12 col-sm-4"
            v-for="(plugin, index) in searchResults"
            :key="index"
          />
          <ProviderCardRow
            v-show="view === 'list'"
            :provider="plugin"
            class="col-xs-12 col-sm-12"
            v-for="(plugin, index) in searchResults"
            :key="`card_row_${index}`"
          />
        </div>
        <div v-else class="artifact-grid row row-flex row-flex-wrap">
          <ProviderCardRow
            v-show="view === 'list'"
            :provider="plugin"
            class="col-xs-12 col-sm-12"
            v-for="(plugin, index) in plugins"
            :key="`card_row_${index}`"
          />

          <ProviderCard
            v-show="view === 'grid'"
            :provider="plugin"
            class="artifact col-xs-12 col-sm-4"
            v-for="(plugin, index) in plugins"
            :key="`card_${index}`"
          />
          <div v-show="view === 'detail'" class="col-sm-4 details-checkbox-column">
            <div
              style="max-height: 80vh;overflow-y: scroll; display:inline-block;"
              class="flex-col"
            >
              <div v-for="(service, index) in pluginsByService" :key="index">
                <div v-if="service.providers.length">
                  <h4 class="checkbox-group-title">{{service.service | splitAtCapitalLetter }}</h4>
                  <ul>
                    <li v-for="(plugin, index) in service.providers" :key="index">
                      <label>
                        <input
                          type="checkbox"
                          v-model="checkedServiceProviders"
                          :value="{serviceName: service.service, providerName: plugin.name}"
                        >
                        {{plugin.title}}
                      </label>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
          <div v-show="view === 'detail'" class="col-sm-8 details-output">
            <div
              style="display: inline-block;max-height: 80vh;overflow-y: scroll;"
              class="flex-col"
            >
              <div v-if="!providersDetails || providersDetails.length === 0">
                <div class="card">
                  <div class="card-content" style="text-align:center">
                    <h3 style="margin:0;">Select a Provider for more information.</h3>
                  </div>
                </div>
              </div>
              <div v-for="(details, index) in providersDetails" :key="index">
                <div class="card">
                  <div class="card-header">
                    <h3 style="margin:0;" class="card-title">{{details.response.title}}</h3>
                    <h5 style="margin:0;">{{details.provider.serviceName | splitAtCapitalLetter }}</h5>
                  </div>
                  <hr>
                  <div class="card-content">
                    <p>
                      Provider Name:
                      <code>{{details.response.name}}</code>
                    </p>
                    <p>{{details.response.desc}}</p>
                    <ul class="provider-props">
                      <li v-for="(prop, index) in details.response.props" :key="index">
                        <div class="row">
                          <div class="col-xs-12 col-sm-3">
                            <strong>{{prop.title}}</strong>
                          </div>
                          <div class="col-xs-12 col-sm-9 provider-prop-divs">
                            <div>{{prop.desc}}</div>
                            <div>
                              <strong>Configure Project:</strong>
                              <code>project.plugin.{{details.provider.serviceName}}.{{details.response.name}}.{{prop.name}}={{prop.defaultValue}}</code>
                            </div>
                            <div>
                              <strong>Configure Framework:</strong>
                              <ConfigureFrameworkString
                                :serviceName="details.provider.serviceName"
                                :provider="details.response"
                                :prop="prop"
                              />
                            </div>
                            <div class="row">
                              <div class="col-xs-12 col-sm-3" v-if="prop.defaultValue">
                                <strong>Default value:</strong>
                                <code>{{prop.defaultValue}}</code>
                              </div>
                              <div
                                class="col-xs-12 col-sm-9"
                                v-if="prop.allowed && prop.allowed.length"
                              >
                                <strong>Allowed values:</strong>
                                <ul class="values">
                                  <li v-for="(allowedItem, index) in prop.allowed" :key="index">
                                    <code>{{allowedItem}}</code>
                                  </li>
                                </ul>
                              </div>
                            </div>
                          </div>
                        </div>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <modal
      v-if="provider"
      v-model="isModalOpen"
      :title="provider.title"
      @hide="handleModalClose"
      ref="modal"
      id="provider-modal"
      size="lg"
    >
      <p>
        Provider Name:
        <code>{{provider.name}}</code>
      </p>
      <p>{{provider.desc}}</p>
      <ul class="provider-props">
        <li v-for="(prop, index) in provider.props" :key="index">
          <div class="row">
            <div class="col-xs-12 col-sm-3">
              <strong>{{prop.title}}</strong>
            </div>
            <div class="col-xs-12 col-sm-9 provider-prop-divs">
              <div>{{prop.desc}}</div>
              <div>
                <strong>Configure Project:</strong>
                <code>project.plugin.{{serviceName}}.{{provider.name}}.{{prop.name}}={{prop.defaultValue}}</code>
              </div>
              <div>
                <strong>Configure Framework:</strong>
                <ConfigureFrameworkString
                  :serviceName="serviceName"
                  :provider="provider"
                  :prop="prop"
                />
              </div>
              <div class="row">
                <div class="col-xs-12 col-sm-3" v-if="prop.defaultValue">
                  <strong>Default value:</strong>
                  <code>{{prop.defaultValue}}</code>
                </div>
                <div class="col-xs-12 col-sm-9" v-if="prop.allowed && prop.allowed.length">
                  <strong>Allowed values:</strong>
                  <ul class="values">
                    <li v-for="(allowedItem, index) in prop.allowed" :key="index">
                      <code>{{allowedItem}}</code>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </li>
      </ul>
      <div slot="footer">
        <btn @click="handleModalClose">Close</btn>
      </div>
    </modal>
  </div>
</template>

<script>
const FuseSearchOptions = {
  shouldSort: true,
  threshold: 0.2,
  location: 0,
  // distance: 100,
  // maxPatternLength: 32,
  minMatchCharLength: 1,
  keys: ["display", "name"]
};

import axios from "axios";

import { mapState, mapActions, mapGetters } from "vuex";
import ProviderCard from "../components/ProviderCard";
import ProviderCardRow from "../components/ProviderCardRow";
import ConfigureFrameworkString from "../components/ConfigureFrameworkString";

export default {
  name: "PluginConfigurationView",
  components: { ProviderCard, ProviderCardRow, ConfigureFrameworkString },
  filters: {
    splitAtCapitalLetter: function(value) {
      if (!value) return "";
      value = value.toString();
      return value.match(/[A-Z][a-z]+|[0-9]+/g).join(" ");
    }
  },
  methods: {
    ...mapActions("plugins", [
      "initData",
      "setServiceFacet",
      "getServices",
      "getProvidersListByService",
      "getProvidersInfo"
    ]),
    ...mapActions("modal", ["closeModal"]),
    handleModalClose() {
      this.closeModal();
    },
    changeServiceFacet(event) {
      this.setServiceFacet(event.target.value);
    },
    clearSearch() {
      this.searchResults = [];
    },
    search() {
      this.clearSearch();
      this.showWhichPlugins = null;
      if (this.searchString === "") {
        this.searchResults = [];
        return;
      }
      let theRepo = this.plugins;
      this.$search(this.searchString, theRepo, FuseSearchOptions).then(
        results => {
          this.searchResults = results;
        }
      );
    }
  },
  computed: {
    ...mapState("modal", ["modalOpen"]),
    ...mapState("plugins", [
      "plugins",
      "provider",
      "serviceName",
      "services",
      "pluginsByService",
      "providersDetails"
    ]),
    isModalOpen: {
      get: function() {
        return this.modalOpen;
      },
      set: function() {
        this.closeModal().then(() => {
          return this.modalOpen;
        });
      }
    }
  },
  created() {
    this.initData();
    this.getServices();
    this.getProvidersListByService();
  },
  data() {
    return {
      showWhichPlugins: null,
      searchString: "",
      searchIndex: [],
      searchResults: [],
      selectedService: null,
      view: "grid",
      checkedServiceProviders: []
    };
  },
  watch: {
    checkedServiceProviders: function(newVal, oldVal) {
      this.getProvidersInfo(newVal);
    }
  }
};
</script>

<style lang="scss" scoped>
.artifact {
  max-width: 33.33333333%;
}
.btn-group.btn-group.squareish-buttons {
  .btn {
    border-width: 2px;
  }
}
.details-checkbox-column {
  // margin-top: 1em;
  // max-height: 80vh;
  // overflow-y: scroll;
  // display: inline-block;
  & > div > div:first-child > div > .checkbox-group-title {
    margin-top: 0;
  }
  ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }
}
.details-output {
  margin-top: 1em;
  ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }
}
</style>
<style lang="scss">
// Modal Styles
#provider-modal {
  .modal-dialog.modal-lg {
    width: 90%;
  }
  .provider-prop-divs > div {
    margin-bottom: 1em;
  }
  .values,
  .provider-props {
    list-style: none;
    display: inline;
  }
  .provider-props > li {
    margin-top: 1em;
    border-top: 1px solid #ebebeb;
    padding-top: 1em;
  }
  .values li {
    display: inline;
    margin-right: 1em;
    // &:after {
    //   content: ",";
    // }
  }
}
</style>
